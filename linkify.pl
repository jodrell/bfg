#!/usr/bin/env perl
#
# this script scans the supplied file, and adds relative path URLs to links that
# don't have them, based on a manually-maintained mapping. So [rulebook] will be
# converted [rulebook](the-rules.md).
#
# Note that the file is edited in place!
#
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Slurp;
use File::Spec;
use List::Util qw(uniq);
use YAML::XS;
use vars qw($LINKS $BASE $FILE $TEXT $C @LINKS @MISSING);
use common::sense;

$LINKS  = YAML::XS::LoadFile(File::Spec->catfile(dirname(__FILE__), q{links.yml}));
$BASE   = File::Spec->catdir(dirname(__FILE__), q{docs});
$FILE   = abs_path($ARGV[0]);

if (!-e $FILE) {
    printf(STDERR "File '%s' not found\n", $FILE);
    exit(1);
}

$TEXT = join(q{}, read_file($FILE));

@LINKS = ($TEXT =~ /\[([^\]]+?)\][^\(]/sg);
foreach my $link (@LINKS) {
    my $key = lc($link);
    $key =~ s/[ \t\r\n]+/ /g;
    $key =~ s/^ +//g;
    $key =~ s/ +$//g;

    # the source text has many [???] placeholders which must be ignored
    next if ($key =~ /^\?{2,3}/);

    if (!exists($LINKS->{$key})) {
        #
        # no path available, so add to @MISSING for later reporting
        #
        push(@MISSING, $key);

        next;
    }

    my $url_ref = resolve_url($LINKS->{$key});

    my $replacement = sprintf('[%s](%s)', $link, $url_ref);

    $TEXT =~ s/\[$link\]([^\(])/$replacement$1/g;
    $C++;
}

if (scalar(@MISSING) > 0) {
    printf(STDERR "Missing links for the following keys:\n  %s\n", join("\n  ", sort(uniq(@MISSING))));
    exit(1);
}

if ($C < 1) {
    say STDERR q{No changes to make!};
    exit(0);
}

write_file($FILE, $TEXT);

say STDERR qq{updated $FILE};

#
# returns a relative path between the supplied file and the link target,
# preserving the anchor, if present
#
sub resolve_url {
    my ($path, $anchor) = split(/#/, shift, 2);

    my $ctx = $FILE;
    $ctx =~ s/^$BASE\///g;

    my $rel = File::Spec->abs2rel($path, dirname($ctx));

    $rel .= q{#}.$anchor if ($anchor);

    return $rel;
}
