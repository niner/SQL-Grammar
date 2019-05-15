my @tags;

my $nr = 0;
my $line;
for lines() {
    $nr++;
    next if $nr < 5;
    next if $_.starts-with('--##') or $_.starts-with('--@@');
    if $_ ~~ /^^ '--' ('/')?(\w+)/ {
        if $0 {
            die "invalid end tag $1, expected @tags[*-1] at line $nr" if @tags[*-1] ne $1;
            @tags.pop;
            #until @tags.pop eq $1 { }
        }
        else {
            @tags.push: $1 unless $1 eq 'hr' | 'li' | 'br';
        }
    }
    else {
        next if @tags;

        if $_.starts-with("\t") {
            $line ~= $_;
        }
        else {
            say $line if $line;
            $line = $_;
        }
    }
}
say $line;
