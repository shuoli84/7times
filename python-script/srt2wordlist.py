import pysrt
import sys
import nltk
from nltk.corpus import stopwords
from nltk.stem.snowball import SnowballStemmer
import re
import json
import glob
import en

stemmer = SnowballStemmer("english")

def stem(token):
  r = str(en.sentence.tag(token.encode('utf-8')))
  print r
  if len(r.split('/')) != 2:
    return token
  word,tag = r.split('/')
  if tag == 'VBD' or tag == 'VBG' or tag == 'VBN' or tag == 'VBZ' or tag == 'VBP':
    return en.verb.infinitive(word.lower())
  if tag == 'NNP' or tag == 'NNS':
    return en.noun.singular(word.lower())
  if tag == 'JJ' or tag == 'NN' or tag == 'VB' or tag == 'RB' or tag == 'UH' or tag == 'IN' or tag == 'PRP':
    return word.lower()

  return word
  

def totalSeconds(sub):
    return sub.start.hours * 3600 + sub.start.minutes * 60 + sub.start.seconds

simpleWords = [w.strip() for w in open('./cet4.txt').readlines()]

filename = sys.argv[1]
output_filename = 'extracted.words'
span_in_seconds = int(sys.argv[2])

all_words_list = [w.strip() for w in open('./wordsEn.txt').readlines()]
all_words_set = set(all_words_list)
print "Loaded all words list " + str(len(all_words_list)) + " words loaded"

line2filename = {}
word2line = {}
alllines = []
for file in glob.glob(filename):
    lines = pysrt.open(file, encoding='iso-8859-1')
    lines = lines[:-1]
    for line in lines:
      line2filename[line] = file
    alllines += lines

lines = alllines

line2tokens = {}
for line in lines:
  line2tokens[line] = [w.strip(",.;!'\"-/~") for w in [w.replace("'s", '') for w in nltk.word_tokenize(line.text)]]

tokens = [line2tokens[line] for line in lines]

tokens = [t for sub in tokens for t in sub]

print 'Get ' + str(len(tokens)) + ' tokens'

tokens = list(set(tokens))

print 'Reduce duplicate to ' + str(len(tokens)) + ' tokens'

# change the form and do the dedup again
originalForWord = {}
resultList = []
for t in tokens:
  n = stem(t)
  originalForWord[n] = originalForWord.get(n) or [] 
  originalForWord[n].append(t)
  resultList.append(n)

tokens = resultList
print tokens
  
tokens = list(set(tokens))

print 'Sort it'
tokens.sort()

regex = re.compile('[a-zA-Z]')
tokens = filter(regex.search, tokens)
tokens = [w for w in tokens if w.lower() in all_words_set]

print 'Remove non words ' + str(len(tokens)) + ' tokens'

tokens = [t for t in tokens if len(t) > 2]

print 'Remove less than 2 letters ' + str(len(tokens)) + ' tokens'

tokens = [t for t in tokens if t.lower() not in simpleWords]
tokens = [t for t in tokens if stemmer.stem(t.lower()) not in simpleWords]

print 'Filter simple words ' + str(len(tokens)) + ' tokens'

tokens = [t for t in tokens if t.lower() not in stopwords.words("english")]

print 'Filter for stop words ' + str(len(tokens)) + ' tokens'

results = []
for word in tokens:
  result = {}
  result['word'] = word
  linesForWord = []
  for index, line in enumerate(lines):
    line_entry = {}
    
    for w in originalForWord[word]:
      if w in line2tokens[line]:
        linetext = ''
        if index >= 1 and totalSeconds(line) - totalSeconds(lines[index-1]) <= span_in_seconds:
          linetext += lines[index-1].text.replace("\n", ' ') + '\n'
        linetext += line.text.replace("\n", ' ').replace(w, '<b>'+w+'</b>')
        if index+1 < len(lines) and totalSeconds(lines[index+1]) - totalSeconds(line) <= span_in_seconds:
          linetext += '\n' + lines[index+1].text.replace("\n", ' ')
        line_entry['text'] = linetext
        line_entry['time'] = totalSeconds(line)
        line_entry['filename'] = line2filename[line]
        linesForWord.append(line_entry)

  result['lines'] = linesForWord
  results.append(result)

resultObject = {}
resultObject['words'] = results

output = open(output_filename, 'w')
output.write(json.dumps(resultObject, indent=4).encode('utf-8'))
print 'write output to ' + output_filename
output.close()

output = open(output_filename + '.list', 'w')
output.write('\n'.join(tokens).encode('utf-8'))
print 'write words to ' + output_filename + '.list'
output.close()
