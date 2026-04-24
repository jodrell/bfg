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
use common::sense;

my $file = abs_path($ARGV[0]);
my $base = abs_path(dirname(__FILE__)).q{/docs};

if (!-e $file) {
    printf(STDERR "File '%s' not found\n", $file);
    exit(1);
}

my $links = {
    '*all ahead full*'                          => q{the-rules.md#all-ahead-full},
    '*brace for impact*'                        => q{the-rules.md#brace-for-impact},
    '*burn retros*'                             => q{the-rules.md#burn-retros},
    '*come to new heading*'                     => q{the-rules.md#come-to-new-heading},
    '*comes to new heading*'                    => q{the-rules.md#come-to-new-heading},
    '*lock on*'                                 => q{the-rules.md#lock-on},
    '*lock-on*'                                 => q{the-rules.md#lock-on},
    '*reload ordnance*'                         => q{the-rules.md#reload-ordnance},
    '*reload*'                                  => q{the-rules.md#reload-ordnance},
    'appeals'                                   => q{campaign-rules.md#6-appeals},
    'aspect warrior host'                       => q{fleet-lists/eldar.md#aspect-warrior-hosts},
    'aspect warrior'                            => q{fleet-lists/eldar.md#aspect-warrior-hosts},
    'aspect warriors'                           => q{fleet-lists/eldar.md#aspect-warrior-hosts},
    'assault boat'                              => q{the-ordnance-phase.md#assault-boats},
    'assault boats'                             => q{the-ordnance-phase.md#assault-boats},
    'asteroid field'                            => q{the-battlefield.md#asteroid-fields},
    'asteroid fields'                           => q{the-battlefield.md#asteroid-fields},
    'attack (initiative) rating'                => q{scenarios.md#using-an-attack-rating},
    'attack (or initiative) rating'             => q{scenarios.md#using-an-attack-rating},
    'attack craft'                              => q{the-ordnance-phase.md#attack-craft},
    'attack or initiative rating'               => q{scenarios.md#using-an-attack-rating},
    'batteries'                                 => q{the-shooting-phase.md#direct-firing-weapons-batteries},
    'battlezone'                                => q{the-battlefield.md},
    'bearing compass'                           => q{the-rules.md#the-bearing-compass},
    'blast marker'                              => q{the-shooting-phase.md#blast-markers},
    'blast markers'                             => q{the-shooting-phase.md#blast-markers},
    'board'                                     => q{the-end-phase.md#boarding-actions},
    'boarding action'                           => q{the-end-phase.md#boarding-actions},
    'boarding actions'                          => q{the-end-phase.md#boarding-actions},
    'boarding strength'                         => q{the-end-phase.md#boarding-value},
    'boarding torpedoes'                        => q{the-ordnance-phase.md#boarding-torpedoes},
    'boarding value'                            => q{the-end-phase.md#boarding-value},
    'boarding'                                  => q{the-end-phase.md#boarding-actions},
    'bomber'                                    => q{the-ordnance-phase.md#bombers},
    'bombers'                                   => q{the-ordnance-phase.md#bombers},
    'brace'                                     => q{the-rules.md#brace-for-impact},
    'braced'                                    => q{the-rules.md#brace-for-impact},
    'campaigns'                                 => q{campaign-rules.md},
    'catastrophic damage'                       => q{the-shooting-phase.md#catastrophic-damage},
    'celestial phenomena'                       => q{the-battlefield.md#celestial-phenomena},
    'command check'                             => q{the-rules.md#taking-command-checks},
    'command checks'                            => q{the-rules.md#taking-command-checks},
    'crew skill'                                => q{campaign-rules.md#crew-skills},
    'crew skills'                               => q{campaign-rules.md#crew-skills},
    'crippled'                                  => q{the-shooting-phase.md#crippled-ships},
    'crippling'                                 => q{the-shooting-phase.md#crippled-ships},
    'critical damage'                           => q{the-shooting-phase.md#critical-hits},
    'critical hit'                              => q{the-shooting-phase.md#critical-hits},
    'critical hits table'                       => q{the-shooting-phase.md#critical-hits-table},
    'critical hits'                             => q{the-shooting-phase.md#critical-hits},
    'critical'                                  => q{the-shooting-phase.md#critical-hits},
    'damage control'                            => q{the-end-phase.md#damage-control},
    'damage'                                    => q{the-shooting-phase.md#damage},
    'deep space celestial phenomena generator'  => q{the-battlefield.md#6-deep-space-generator},
    'deep space'                                => q{the-battlefield.md#6-deep-space-generator},
    'disengage'                                 => q{the-movement-phase.md#disengaging-from-combat},
    'disengages'                                => q{the-movement-phase.md#disengaging-from-combat},
    'end phase'                                 => q{the-end-phase.md},
    'fighters'                                  => q{the-ordnance-phase.md#fighters},
    'gas and dust clouds'                       => q{the-battlefield.md#gas-and-dust-clouds},
    'gas clouds'                                => q{the-battlefield.md#gas-and-dust-clouds},
    'gravity wells'                             => q{the-battlefield.md#typical-gravity-wells},
    'guided'                                    => q{fleet-lists/refits.md#guided-torpedoes},
    'gunnery table'                             => q{the-shooting-phase.md#gunnery-table},
    'gunz batteries'                            => q{the-shooting-phase.md#direct-firing-weapons-batteries},
    'hit & run attack'                          => q{the-end-phase.md#hit-and-run-attacks},
    'hit & run attacks'                         => q{the-end-phase.md#hit-and-run-attacks},
    'hit & run'                                 => q{the-end-phase.md#hit-and-run-attacks},
    'hit and run attack'                        => q{the-end-phase.md#hit-and-run-attacks},
    'hit and run attacks'                       => q{the-end-phase.md#hit-and-run-attacks},
    'hit-&-run raids'                           => q{the-end-phase.md#hit-and-run-attacks},
    'hit-and run attack'                        => q{the-end-phase.md#hit-and-run-attacks},
    'hit-and run attacks'                       => q{the-end-phase.md#hit-and-run-attacks},
    'hit-and-run attack'                        => q{the-end-phase.md#hit-and-run-attacks},
    'hit-and-run attacks'                       => q{the-end-phase.md#hit-and-run-attacks},
    'hit-and-run raids'                         => q{the-end-phase.md#hit-and-run-attacks},
    'hit-and-run teleport attacks'              => q{the-end-phase.md#teleport-attacks},
    'holofields'                                => q{fleet-lists/eldar.md#holofields},
    'imperial navy'                             => q{fleet-lists/imperial-navy.md},
    'lance'                                     => q{the-shooting-phase.md#direct-firing-lances},
    'lances'                                    => q{the-shooting-phase.md#direct-firing-lances},
    'launch limits'                             => q{the-ordnance-phase.md#fleet-ordnance-limits},
    'launch ordnance'                           => q{the-ordnance-phase.md#launching-ordnance},
    'leadership check to ram'                   => q{the-movement-phase.md#all-ahead-full-ramming-speed},
    'leadership check'                          => q{the-rules.md#taking-command-checks},
    'leadership checks'                         => q{the-rules.md#taking-command-checks},
    'leadership tests'                          => q{the-rules.md#taking-command-checks},
    'leadership'                                => q{the-rules.md#leadership},
    'low orbit table'                           => q{the-battlefield.md#fighting-in-low-orbit},
    'low orbit'                                 => q{the-battlefield.md#fighting-in-low-orbit},
    'mark of chaos'                             => q{fleet-lists/chaos.md#marks-of-chaos},
    'moons'                                     => q{the-battlefield.md#moons},
    'move'                                      => q{the-movement-phase.md},
    'movement phase'                            => q{the-movement-phase.md},
    'movement rules'                            => q{the-movement-phase.md},
    'movement'                                  => q{the-movement-phase.md},
    'nova cannon'                               => q{the-shooting-phase.md#nova-cannon},
    'ordnance attacks'                          => q{the-movement-phase.md},
    'ordnance phase'                            => q{the-ordnance-phase.md},
    'ordnance'                                  => q{the-ordnance-phase.md},
    'outer reaches'                             => q{the-battlefield.md#5-outer-reaches-generator},
    'planet'                                    => q{the-battlefield.md#planets},
    'planetary assault'                         => q{scenarios/planetary-assault.md},
    'planetary defences'                        => q{fleet-lists/planetary-defences.md},
    'planetary defenses'                        => q{fleet-lists/planetary-defences.md},
    'planets'                                   => q{the-battlefield.md#planets},
    'primary biosphere'                         => q{the-battlefield.md#4-primary-biosphere-generator},
    'pulsar lance'                              => q{fleet-lists/eldar.md#pulsar-lance},
    'radiation bursts'                          => q{the-battlefield.md#radiation-bursts},
    'ram'                                       => q{the-movement-phase.md#all-ahead-full-ramming-speed},
    'ramming'                                   => q{the-movement-phase.md#all-ahead-full-ramming-speed},
    're-roll'                                   => q{the-rules.md#re-rolls},
    're-rolls'                                  => q{the-rules.md#re-rolls},
    'refit'                                     => q{campaign-rules.md#refits},
    'refits'                                    => q{fleet-lists/refits.md},
    'removal of blast markers from planetary defences' => q{planetary-defences.md#removal-of-blast-markers},
    'renown'                                    => q{campaign-rules.md#renown},
    'repair critical damage'                    => q{the-end-phase.md#damage-control},
    'repaired'                                  => q{the-end-phase.md#damage-control},
    'repairing critical damage'                 => q{the-end-phase.md#damage-control},
    'resilient attack craft'                    => q{the-ordnance-phase.md#resilient-attack-craft},
    'resilient'                                 => q{the-ordnance-phase.md#resilient-attack-craft},
    'rings'                                     => q{the-battlefield.md#ringed-planets},
    'scenarios'                                 => q{scenarios.md},
    'shield'                                    => q{the-shooting-phase.md#shields},
    'shielding'                                 => q{the-shooting-phase.md#shields},
    'shields'                                   => q{the-shooting-phase.md#shields},
    'shoot'                                     => q{the-shooting-phase.md},
    'shooting phase'                            => q{the-shooting-phase.md},
    'shooting'                                  => q{the-shooting-phase.md},
    'solar flares'                              => q{the-battlefield.md#solar-flares},
    'special order command check'               => q{the-rules.md#special-orders},
    'special order'                             => q{the-rules.md#special-orders},
    'special orders'                            => q{the-rules.md#special-orders},
    'squadron'                                  => q{squadrons.md},
    'squadroned'                                => q{squadrons.md},
    'squadrons'                                 => q{squadrons.md},
    'sub-plot'                                  => q{scenarios.md#sub-plots},
    'subplots'                                  => q{scenarios.md#sub-plots},
    'sunward edge'                              => q{the-battlefield.md#fighting-sunward},
    'sunward table edge'                        => q{the-battlefield.md#fighting-sunward},
    'teleport attack'                           => q{the-end-phase.md#teleport-attacks},
    'teleport attacks'                          => q{the-end-phase.md#teleport-attacks},
    'teleport hit and run attack'               => q{the-end-phase.md#teleport-attacks},
    'teleport hit and run attacks'              => q{the-end-phase.md#teleport-attacks},
    'teleport'                                  => q{the-end-phase.md#teleport-attacks},
    'teleportation'                             => q{the-end-phase.md#teleport-attacks},
    'teleporter'                                => q{the-end-phase.md#teleport-attacks},
    'teleporters'                               => q{the-end-phase.md#teleport-attacks},
    'the movement phase'                        => q{the-movement-phase.md},
    'the shooting phase'                        => q{the-shooting-phase.md},
    'torpedo bombers'                           => q{the-ordnance-phase.md#torpedo-bombers},
    'torpedo'                                   => q{the-ordnance-phase.md#torpedoes},
    'torpedoes'                                 => q{the-ordnance-phase.md#torpedoes},
    'turn'                                      => q{the-movement-phase.md#turning},
    'turret'                                    => q{the-ordnance-phase.md#turrets},
    'turrets'                                   => q{the-ordnance-phase.md#turrets},
    'victory points'                            => q{scenarios.md#victory-points},
    'warp rift'                                 => q{the-battlefield.md#warp-rifts},
    'weapon batteries'                          => q{the-shooting-phase.md#direct-firing-weapons-batteries},
    'weapons batteries'                         => q{the-shooting-phase.md#direct-firing-weapons-batteries},
    'weapons battery'                           => q{the-shooting-phase.md#direct-firing-weapons-batteries},
    'rulebook'                                  => q{the-rules.md},
    'campaign'                                  => q{campaign-rules.md},
    'turn sequence'                             => q{the-turn.md#turn-sequence},
};

my $text = join(q{}, read_file($file));

my @missing;

my @matches = ($text =~ /\[([^\]]+?)\][^\(]/sg);

my $changes = 0;

foreach my $link (@matches) {
    my $key = lc($link);
    $key =~ s/[ \t\r\n]+/ /g;

    # the source text has many [???] placeholders which must be ignored
    next if ($key =~ /^\?{2,3}/);

    if (!exists($links->{$key})) {
        #
        # no path available, so add to @missing for later reporting
        #
        push(@missing, $key);

        next;
    }

    my $url_ref = resolve_url($links->{$key});

    my $replacement = sprintf('[%s](%s)', $link, $url_ref);

    $text =~ s/\[$link\]([^\(])/$replacement$1/g;
    $changes++;
}

if (scalar(@missing) > 0) {
    printf(STDERR "Missing links for the following keys:\n  %s\n", join("\n  ", @missing));
    exit(1);
}

if ($changes < 1) {
    say STDERR q{No changes to make!};
    exit(0);
}

write_file($file, $text);

say STDERR qq{updated $file};

#
# returns a relative path between the supplied file and the link target,
# preserving the anchor, if present
#
sub resolve_url {
    my ($path, $anchor) = split(/#/, shift, 2);

    my $ctx = $file;
    $ctx =~ s/^$base\///g;

    my $rel = File::Spec->abs2rel($path, dirname($ctx));

    $rel .= q{#}.$anchor if ($anchor);

    return $rel;
}
