#!/bin/sh

echo "Running tests"
python ../ltc.py test > /dev/null
if [ "$?" -ne "0" ]
then
  echo "Tests failed"
  exit 1
fi

rm result.txt 2> /dev/null

echo "Testing recovery #1"
words="cover tube shrug thought trick scout extra orphan spin banana civil error hockey ranch vivid round logic stable brass error fork duck bomb soup"
python ../ltc.py recover "$words" | grep "m/44'/2'/0'/0/1 " | awk '{print $2}' > "result.txt"
result=`cat result.txt`
if [ "$result" != "LcU5ynFcA66eiYsss6jzRiXxRTsnAioz8n" ]
then
  echo "Failed to recover expected key"
  exit 1
fi

echo "Testing recovery #2"
words="rabbit screen what outdoor piano price post ostrich sorry swift festival tongue sausage unit shock circle first crowd drive field ticket stairs extra tongue"
python ../ltc.py recover "$words" | grep "m/44'/2'/0'/0/1 " | awk '{print $2}' > "result.txt"
result=`cat result.txt`
if [ "$result" != "Lenp1mE7REZFeXjdT9U8EZW2BhTYs9KzyT" ]
then
  echo "Failed to recover expected key"
  exit 1
fi

echo "Testing recovery #3"
words="language army border you describe kind record require kite catch return shadow rescue town leisure blossom sweet mother enable major bundle medal maximum arrest"
python ../ltc.py recover "$words" hello | grep "m/44'/2'/0'/0/1 " | awk '{print $2}' > "result.txt"
result=`cat result.txt`
if [ "$result" != "LTYN4keUZAv3GdJaJDEi7Qjgg4zNKX5bcL" ]
then
  echo "Failed to recover expected key"
  exit 1
fi

rm result.txt

for i in `seq 1 3`;
do
  rm gen-verify.txt rec-verify.txt 2> /dev/null
  echo "Encode decode no passphrase iteration #$i"

  # Generate
  python ../ltc.py generate additional > gen-output.txt
  cat gen-output.txt | grep "Entropy as words" | cut -c 24- > mnemonic.txt

  # Recover
  mnemonic=`cat mnemonic.txt`
  python ../ltc.py recover "$mnemonic" > rec-output.txt

  # Compare
  cat gen-output.txt | tail -n 41 > gen-verify.txt
  cat rec-output.txt | tail -n 41 > rec-verify.txt

  diff gen-verify.txt rec-verify.txt

  if [ "$?" -ne "0" ]
  then
    echo "Failed recovery!"
    exit 1
  fi

done

for i in `seq 1 3`;
do
  rm gen-verify.txt rec-verify.txt 2> /dev/null
  echo "Encode decode with passphrase iteration #$i"

  # Generate
  python ../ltc.py generate additional passphrase > gen-output.txt
  cat gen-output.txt | grep "Entropy as words" | cut -c 24- > mnemonic.txt

  # Recover
  mnemonic=`cat mnemonic.txt`
  python ../ltc.py recover "$mnemonic" passphrase > rec-output.txt

  # Compare
  cat gen-output.txt | tail -n 41 > gen-verify.txt
  cat rec-output.txt | tail -n 41 > rec-verify.txt

  diff gen-verify.txt rec-verify.txt

  if [ "$?" -ne "0" ]
  then
    echo "Failed recovery!"
    exit 1
  fi

done

for i in `seq 1 3`;
do
  rm gen-verify.txt rec-verify.txt 2> /dev/null
  echo "Encode decode different passphrases iteration #$i"

  # Generate
  python ../ltc.py generate additional "passphrase$i" > gen-output.txt
  cat gen-output.txt | grep "Entropy as words" | cut -c 24- > mnemonic.txt

  # Recover
  mnemonic=`cat mnemonic.txt`
  python ../ltc.py recover "$mnemonic" "passphrase$i" > rec-output.txt

  # Compare
  cat gen-output.txt | tail -n 41 > gen-verify.txt
  cat rec-output.txt | tail -n 41 > rec-verify.txt

  diff gen-verify.txt rec-verify.txt

  if [ "$?" -ne "0" ]
  then
    echo "Failed recovery!"
    exit 1
  fi

done

rm gen-verify.txt rec-verify.txt gen-output.txt mnemonic.txt rec-output.txt
