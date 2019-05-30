#!usr/local/bin/perl -w
my $n=0;
while ($line = <>)
{
  chomp $line;
  if ($line =~/>/)
  {
    if ($n==0)
    {
      print "$line\n";
    }
    else
    {
      print "\n$line\n";
    }
    $n+=1;
  }
  else
  {
    print $line;
  }
}
print "\n";

