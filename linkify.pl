#!/usr/bin/env perl
use List::Util qw(uniq);
use Data::Dumper;
use Data::Printer;
use File::Slurp;
use common::sense;

my $links = {
    '*all ahead full*'                  => q{../the-rules.md#all-ahead-full},
    '*brace for impact*'                => q{../the-rules.md#brace-for-impact},
    '*burn retros*'                     => q{../the-rules.md#burn-retros},
    '*come to new heading*'             => q{../the-rules.md#come-to-new-heading},
    '*lock on*'                         => q{../the-rules.md#lock-on},
    '*reload ordnance*'                 => q{../the-rules.md#reload-ordnance},
    '*reload*'                          => q{../the-rules.md#reload-ordnance},
    'appeals'                           => q{../campaign-rules.md#6-appeals},
    'assault boat'                      => q{../the-ordnance-phase.md#assault-boats},
    'assault boats'                     => q{../the-ordnance-phase.md#assault-boats},
    'asteroid fields'                   => q{../the-battlefield.md#asteroid-fields},
    'attack craft'                      => q{../the-ordnance-phase.md#attack-craft},
    'attack or initiative rating'       => q{../scenarios.md#using-an-attack-rating},
    'batteries'                         => q{../the-shooting-phase.md#direct-firing-weapons-batteries},
    'blast marker'                      => q{../the-shooting-phase.md#blast-markers},
    'blast markers'                     => q{../the-shooting-phase.md#blast-markers},
    'board'                             => q{../the-end-phase.md#boarding-actions},
    'boarding action'                   => q{../the-end-phase.md#boarding-actions},
    'boarding actions'                  => q{../the-end-phase.md#boarding-actions},
    'boarding strength'                 => q{../the-end-phase.md#boarding-value},
    'boarding torpedoes'                => q{../the-ordnance-phase.md#boarding-torpedoes},
    'boarding'                          => q{../the-end-phase.md#boarding-actions},
    'bomber'                            => q{../the-ordnance-phase.md#bombers},
    'bombers'                           => q{../the-ordnance-phase.md#bombers},
    'brace'                             => q{../the-rules.md#brace-for-impact},
    'braced'                            => q{../the-rules.md#brace-for-impact},
    'catastrophic damage'               => q{../the-shooting-phase.md#catastrophic-damage},
    'celestial phenomena'               => q{../the-battlefield.md#celestial-phenomena},
    'command check'                     => q{../the-rules.md#taking-command-checks},
    'command checks'                    => q{../the-rules.md#taking-command-checks},
    'crippled'                          => q{../the-shooting-phase.md#crippled-ships},
    'crippling'                         => q{../the-shooting-phase.md#crippled-ships},
    'critical damage'                   => q{../the-shooting-phase.md#critical-hits},
    'critical hit'                      => q{../the-shooting-phase.md#critical-hits},
    'critical hits table'               => q{../the-shooting-phase.md#critical-hits-table},
    'critical hits'                     => q{../the-shooting-phase.md#critical-hits},
    'critical'                          => q{../the-shooting-phase.md#critical-hits},
    'damage'                            => q{../the-shooting-phase.md#damage},
    'disengage'                         => q{../the-movement-phase.md#disengaging-from-combat},
    'end phase'                         => q{../the-end-phase.md},
    'fighters'                          => q{../the-ordnance-phase.md#fighters},
    'gas clouds'                        => q{../the-battlefield.md#gas-and-dust-clouds},
    'gas and dust clouds'               => q{../the-battlefield.md#gas-and-dust-clouds},
    'guided'                            => q{refits.md#guided-torpedoes},
    'gunnery table'                     => q{../the-shooting-phase.md#gunnery-table},
    'hit & run attack'                  => q{../the-end-phase.md#hit-and-run-attacks},
    'hit & run attacks'                 => q{../the-end-phase.md#hit-and-run-attacks},
    'hit & run'                         => q{../the-end-phase.md#hit-and-run-attacks},
    'hit and run attack'                => q{../the-end-phase.md#hit-and-run-attacks},
    'hit and run attacks'               => q{../the-end-phase.md#hit-and-run-attacks},
    'hit-and run attack'                => q{../the-end-phase.md#hit-and-run-attacks},
    'hit-and-run attack'                => q{../the-end-phase.md#hit-and-run-attacks},
    'hit-and-run raids'                 => q{../the-end-phase.md#hit-and-run-attacks},
    'lance'                             => q{../the-shooting-phase.md#direct-firing-lances},
    'lances'                            => q{../the-shooting-phase.md#direct-firing-lances},
    'launch limits'                     => q{../the-ordnance-phase.md#fleet-ordnance-limits},
    'leadership check'                  => q{../the-rules.md#taking-command-checks},
    'leadership checks'                 => q{../the-rules.md#taking-command-checks},
    'leadership'                        => q{../the-rules.md#leadership},
    'movement phase'                    => q{../the-movement-phase.md},
    'movement'                          => q{../the-movement-phase.md},
    'nova cannon'                       => q{../the-shooting-phase.md#nova-cannon},
    'ordnance phase'                    => q{../the-ordnance-phase.md},
    'ordnance'                          => q{../the-ordnance-phase.md},
    'planetary assault'                 => q{../scenarios/planetary-assault.md},
    'planetary defences'                => q{planetary-defences.md},
    'radiation bursts'                  => q{../the-battlefield.md#radiation-bursts},
    'ramming'                           => q{../the-movement-phase.md#all-ahead-full-ramming-speed},
    'refit'                             => q{../campaign-rules.md#refits},
    'renown'                            => q{../campaign-rules.md#renown},
    'repair critical damage'            => q{../the-end-phase.md#damage-control},
    'repaired'                          => q{../the-end-phase.md#damage-control},
    'repairing critical damage'         => q{../the-end-phase.md#damage-control},
    'resilient attack craft'            => q{../the-ordnance-phase.md#resilient-attack-craft},
    'resilient'                         => q{../the-ordnance-phase.md#resilient-attack-craft},
    'shield'                            => q{../the-shooting-phase.md#shields},
    'shielding'                         => q{../the-shooting-phase.md#shields},
    'shields'                           => q{../the-shooting-phase.md#shields},
    'shooting phase'                    => q{../the-shooting-phase.md},
    'shooting'                          => q{../the-shooting-phase.md},
    'solar flares'                      => q{../the-battlefield.md#solar-flares},
    'special order'                     => q{../the-rules.md#special-orders},
    'special orders'                    => q{../the-rules.md#special-orders},
    'subplots'                          => q{../scenarios.md#sub-plots},
    'teleport attack'                   => q{../the-end-phase.md#teleport-attacks},
    'teleport attacks'                  => q{../the-end-phase.md#teleport-attacks},
    'teleport hit and run attack'       => q{../the-end-phase.md#teleport-attacks},
    'teleport hit and run attacks'      => q{../the-end-phase.md#teleport-attacks},
    'teleporter'                        => q{../the-end-phase.md#teleport-attacks},
    'the shooting phase'                => q{../the-shooting-phase.md},
    'torpedo bombers'                   => q{../the-ordnance-phase.md#torpedo-bombers},
    'torpedo'                           => q{../the-ordnance-phase.md#torpedoes},
    'torpedoes'                         => q{../the-ordnance-phase.md#torpedoes},
    'turn'                              => q{../the-movement-phase.md#turning},
    'turret'                            => q{../the-ordnance-phase.md#turrets},
    'turrets'                           => q{../the-ordnance-phase.md#turrets},
    'victory points'                    => q{../scenarios.md#victory-points},
    'warp rift'                         => q{../the-battlefield.md#warp-rifts},
    'weapon batteries'                  => q{../the-shooting-phase.md#direct-firing-weapons-batteries},
    'weapons batteries'                 => q{../the-shooting-phase.md#direct-firing-weapons-batteries},
    'weapons battery'                   => q{../the-shooting-phase.md#direct-firing-weapons-batteries},
    'crew skills'                       => q{../campaign-rules.md#crew-skills},
    'refits'                            => q{refits.md},
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
