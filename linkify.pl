#!/usr/bin/env perl
use List::Util qw(uniq);
use Data::Dumper;
use Data::Printer;
use File::Slurp;
use common::sense;

my $links = {
  'crippled'                    => q{../the-shooting-phase.md#crippled-ships},
  'critical hit'                => q{../the-shooting-phase.md#critical-hits},
  'special orders'              => q{../the-rules.md#special-orders},
  'crippling'                   => q{../the-shooting-phase.md#crippled-ships},
  'turrets'                     => q{../the-ordnance-phase.md#turrets},
  'shields'                     => q{../the-shooting-phase.md#shields},
  'crippled'                    => q{../the-shooting-phase.md#crippled-ships},
  'shields'                     => q{../the-shooting-phase.md#shields},
  'blast markers'               => q{../the-shooting-phase.md#blast-markers},
  'celestial phenomena'         => q{../the-battlefield.md#celestial-phenomena},
  'movement phase'              => q{../the-movement-phase.md},
  'turn'                        => q{../the-movement-phase.md#turning},
  'ordnance'                    => q{../the-ordnance-phase.md},
  'torpedoes'                   => q{../the-ordnance-phase.md#torpedoes},
  'torpedo bombers'             => q{../the-ordnance-phase.md#torpedo-bombers},
  'attack craft'                => q{../the-ordnance-phase.md#attack-craft},
  'bomber'                      => q{../the-ordnance-phase.md#bombers},
  'boarding torpedoes'          => q{../the-ordnance-phase.md#boarding-torpedoes},
  'fighters'                    => q{../the-ordnance-phase.md#fighers},
  '*all ahead full*'            => q{../the-rules.md#all-ahead-full},
  'bombers'                     => q{../the-ordnance-phase.md#bombers},
  'assault boats'               => q{../the-ordnance-phase.md#assault-boats},
  'end phase'                   => q{../the-end-phase.md},
  'boarding action'             => q{../the-end-phase.md#boarding-actions},
  'disengage'                   => q{../the-movement-phase.md#disengaging-from-combat},
  'critical damage'             => q{../the-shooting-phase.md#critical-hits},
  'blast marker'                => q{../the-shooting-phase.md#blast-markers},
  'gunnery table'               => q{../the-shooting-phase.md#gunnery-table},
  '*burn retros*'               => q{../the-rules.md#burn-retros},
  '*come to new heading*'       => q{../the-rules.md#come-to-new-heading},
  'ordnance phase'              => q{../the-ordnance-phase.md},
  'shielding'                   => q{../the-shooting-phase.md#shields},
  'shield'                      => q{../the-shooting-phase.md#shields},
  'gas clouds'                  => q{../the-battlefield.md#gas-and-dust-clouds},
  'repairing critical damage'   => q{../the-end-phase.md#damage-control},
  'repair critical damage'      => q{../the-end-phase.md#damage-control},
  'nova cannon'                 => q{../the-shooting-phase.md#nova-cannon},
  'lance'                       => q{../the-shooting-phase.md#direct-firing-lances},
  'lances'                      => q{../the-shooting-phase.md#direct-firing-lances},
  'weapons battery'             => q{../the-shooting-phase.md#direct-firing-weapons-batteries},
  'weapon batteries'            => q{../the-shooting-phase.md#direct-firing-weapons-batteries},
  'subplots'                    => q{../scenarios.md#sub-plots},
  '*lock on*'                   => q{../the-rules.md#lock-on},
  '*reload*'                    => q{../the-rules.md#reload-ordnance},
  'renown'                      => q{../campaign-rules.md#renown},
  'leadership'                  => q{../the-rules.md#leadership},
};

my $text = join(q{}, read_file(q{/dev/stdin}));

my @matches = ($text =~ /\[([^\]]+?)\][^\(]/sg);

foreach my $link (@matches) {
    my $key = lc($link);
    $key =~ s/[ \t\r\n]+/ /g;

    if (!exists($links->{$key})) {
        die("Missing link: $key");

    } else {
        my $rep = sprintf('[%s](%s)', $link, $links->{$key});
        $text =~ s/\[$link\]([^\(])/$rep$1/g;

    }
}

say $text;
