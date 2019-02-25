#!/bin/bash

oov_wordlist_in=$1
# text file
# input: wordlist

oov_lex_out=$2
# text file
# output: dictionary

language=$3
# string UTF-8
# currently only available: dutch

N=$4
# integer > 0
# if not specified, this should default to 1

# directory in which model.fst is located
modeldir=/home/ltenbosch/CGN_KALDI_FA/train_$language

# directory where KALDI binaries for phonetisaurus are located
KALDIbin=/vol/tensusers2/eyilmaz/local/bin
export PATH=$KALDIbin:$PATH

# the actual call
phonetisaurus-apply --model $modeldir/model.fst --word_list $oov_wordlist_in -n $N > $oov_lex_out 



