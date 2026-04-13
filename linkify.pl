#!/usr/bin/env perl
use List::Util qw(uniq);
use Data::Dumper;
use Data::Printer;
use File::Slurp;
use common::sense;

my $links = {
  '*all ahead full*'            => q{../the-rules.md#all-ahead-full},
  '*burn retros*'               => q{../the-rules.md#burn-retros},
  '*come to new heading*'       => q{../the-rules.md#come-to-new-heading},
  '*lock on*'                   => q{../the-rules.md#lock-on},
  '*reload*'                    => q{../the-rules.md#reload-ordnance},
  '*reload ordnance*'           => q{../the-rules.md#reload-ordnance},
  '*brace for impact*'          => q{../the-rules.md#brace-for-impact},
  'braced'                      => q{../the-rules.md#brace-for-impact},
  'appeals'                     => q{../campaign-rules.md#6-appeals},
  'assault boat'                => q{../the-ordnance-phase.md#assault-boats},
  'assault boats'               => q{../the-ordnance-phase.md#assault-boats},
  'asteroid fields'             => q{../the-battlefield.md#asteroid-fields},
  'attack craft'                => q{../the-ordnance-phase.md#attack-craft},
  'blast marker'                => q{../the-shooting-phase.md#blast-markers},
  'blast markers'               => q{../the-shooting-phase.md#blast-markers},
  'brace'                       => q{../the-rules.md#brace-for-impact},
  'boarding action'             => q{../the-end-phase.md#boarding-actions},
  'boarding actions'            => q{../the-end-phase.md#boarding-actions},
  'board'                       => q{../the-end-phase.md#boarding-actions},
  'boarding'                    => q{../the-end-phase.md#boarding-actions},
  'boarding torpedoes'          => q{../the-ordnance-phase.md#boarding-torpedoes},
  'bomber'                      => q{../the-ordnance-phase.md#bombers},
  'bombers'                     => q{../the-ordnance-phase.md#bombers},
  'catastrophic damage'         => q{../the-shooting-phase.md#catastrophic-damage},
  'celestial phenomena'         => q{../the-battlefield.md#celestial-phenomena},
  'command check'               => q{../the-rules.md#taking-command-checks},
  'command checks'              => q{../the-rules.md#taking-command-checks},
  'crippled'                    => q{../the-shooting-phase.md#crippled-ships},
  'crippled'                    => q{../the-shooting-phase.md#crippled-ships},
  'crippling'                   => q{../the-shooting-phase.md#crippled-ships},
  'critical damage'             => q{../the-shooting-phase.md#critical-hits},
  'critical hit'                => q{../the-shooting-phase.md#critical-hits},
  'critical hits'               => q{../the-shooting-phase.md#critical-hits},
  'critical hits table'         => q{../the-shooting-phase.md#critical-hits-table},
  'damage'                      => q{../the-shooting-phase.md#damage},
  'disengage'                   => q{../the-movement-phase.md#disengaging-from-combat},
  'end phase'                   => q{../the-end-phase.md},
  'fighters'                    => q{../the-ordnance-phase.md#fighers},
  'gas clouds'                  => q{../the-battlefield.md#gas-and-dust-clouds},
  'gunnery table'               => q{../the-shooting-phase.md#gunnery-table},
  'hit & run'                   => q{../the-end-phase.md#hit-and-run-attacks},
  'hit & run attacks'           => q{../the-end-phase.md#hit-and-run-attacks},
  'hit & run attack'            => q{../the-end-phase.md#hit-and-run-attacks},
  'hit and run attacks'         => q{../the-end-phase.md#hit-and-run-attacks},
  'hit and run attack'          => q{../the-end-phase.md#hit-and-run-attacks},
  'hit-and-run attack'          => q{../the-end-phase.md#hit-and-run-attacks},
  'hit-and run attack'          => q{../the-end-phase.md#hit-and-run-attacks},
  'hit-and-run raids'           => q{../the-end-phase.md#hit-and-run-attacks},
  'lance'                       => q{../the-shooting-phase.md#direct-firing-lances},
  'lances'                      => q{../the-shooting-phase.md#direct-firing-lances},
  'launch limits'               => q{../the-ordnance-phase.md#fleet-ordnance-limits},
  'leadership'                  => q{../the-rules.md#leadership},
  'leadership check'            => q{../the-rules.md#taking-command-checks},
  'movement phase'              => q{../the-movement-phase.md},
  'nova cannon'                 => q{../the-shooting-phase.md#nova-cannon},
  'ordnance phase'              => q{../the-ordnance-phase.md},
  'ordnance'                    => q{../the-ordnance-phase.md},
  'radiation bursts'            => q{../the-battlefield.md#radiation-bursts},
  'ramming'                     => q{../the-movement-phase.md#all-ahead-full-ramming-speed},
  'renown'                      => q{../campaign-rules.md#renown},
  'refit'                       => q{../campaign-rules.md#refits},
  'resilient'                   => q{../the-ordnance-phase.md#resilient-attack-craft},
  'resilient attack craft'      => q{../the-ordnance-phase.md#resilient-attack-craft},
  'repair critical damage'      => q{../the-end-phase.md#damage-control},
  'repairing critical damage'   => q{../the-end-phase.md#damage-control},
  'shield'                      => q{../the-shooting-phase.md#shields},
  'shielding'                   => q{../the-shooting-phase.md#shields},
  'shields'                     => q{../the-shooting-phase.md#shields},
  'shields'                     => q{../the-shooting-phase.md#shields},
  'solar flares'                => q{../the-battlefield.md#solar-flares},
  'special orders'              => q{../the-rules.md#special-orders},
  'subplots'                    => q{../scenarios.md#sub-plots},
  'teleport attacks'            => q{../the-end-phase.md#teleport-attacks},
  'teleport attack'             => q{../the-end-phase.md#teleport-attacks},
  'teleporter'                  => q{../the-end-phase.md#teleport-attacks},
  'torpedo bombers'             => q{../the-ordnance-phase.md#torpedo-bombers},
  'torpedo'                     => q{../the-ordnance-phase.md#torpedoes},
  'torpedoes'                   => q{../the-ordnance-phase.md#torpedoes},
  'turn'                        => q{../the-movement-phase.md#turning},
  'turrets'                     => q{../the-ordnance-phase.md#turrets},
  'turret'                      => q{../the-ordnance-phase.md#turrets},
  'weapon batteries'            => q{../the-shooting-phase.md#direct-firing-weapons-batteries},
  'weapons batteries'           => q{../the-shooting-phase.md#direct-firing-weapons-batteries},
  'weapons battery'             => q{../the-shooting-phase.md#direct-firing-weapons-batteries},
  'warp rift'                   => q{../the-battlefield.md#warp-rifts},
  'planetary assault'           => q{../scenarios/planetary-assault.md},
};

my $text = join(q{}, read_file(q{/dev/stdin}));

my @matches = ($text =~ /\[([^\]]+?)\][^\(]/sg);

foreach my $link (@matches) {
    my $key = lc($link);
    $key =~ s/[ \t\r\n]+/ /g;

    next if (q{???} eq $key);

    if (!exists($links->{$key})) {
        die("Missing link: $key");

    } else {
        my $rep = sprintf('[%s](%s)', $link, $links->{$key});
        $text =~ s/\[$link\]([^\(])/$rep$1/g;

    }
}

say $text;
