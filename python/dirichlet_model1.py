# Example of usage of cpyp python module
import sys
import cpyp
import random
import argparse

class Bitext:
	def __init__(self):
		self.src_dict = {}
		self.tgt_dict = {}
		self.src_words = []
		self.tgt_words = []
		self.sentences = []

	def __len__(self):
		return len(self.sentences)

	def __getitem__(self, i):
		return self.sentences[i]

	def convert_src(self, item):
		if isinstance(item, basestring):
			if not item in self.src_dict:
				self.src_dict[item] = len(self.src_words)
				self.src_words.append(item)
			return self.src_dict[item]
		else:
			return self.src_words[item]

	def convert_tgt(self, item):
		if isinstance(item, basestring):
			if not item in self.tgt_dict:
				self.tgt_dict[item] = len(self.tgt_words)
				self.tgt_words.append(item)
			return self.tgt_dict[item]
		else:
			return self.tgt_words[item]

	def read(self, stream):
		for line in stream:
			src, tgt = [part.strip() for part in line.split('|||')]
			src = [token for token in src.split() if len(token) > 0]
			tgt = [token for token in tgt.split() if len(token) > 0]
			src = [self.convert_src(w) for w in src]
			tgt = [self.convert_tgt(w) for w in tgt]
			self.sentences.append((src, tgt))

def mult(probs):
	total = sum(probs)
	r = random.uniform(0.0, total)
	t = 0.0
	for i, p in enumerate(probs):
		t += p
		if t > r:
			return i
	assert False

parser = argparse.ArgumentParser()
parser.add_argument('bitext')
parser.add_argument('-n', '--samples', type=int)
args = parser.parse_args()

bitext = Bitext()
bitext.read(open(args.bitext))
uniform_tgt_word = 1.0 / len(bitext.tgt_dict)
num_samples = args.samples

base = cpyp.CRP(0.0, 1.0)
ttable = [cpyp.CRP(0.0, uniform_tgt_word) for source_word in bitext.src_dict.keys()]
tpr = cpyp.TiedParameterResampler(1, 1, 1, 1, 0.1, 1)
for src_ttable in ttable:
 	tpr.insert(src_ttable)

alignments = [[0 for w in tgt] for src, tgt in bitext]

for sample in range(num_samples):
	print 'beginning sample %d' % sample
	for i, (src, tgt) in enumerate(bitext):
		for n, t in enumerate(tgt):
			if sample == 0:
				a = random.randint(0, len(src) - 1)
			else:
				a = alignments[i][n]
				s = src[a]
				if ttable[s].decrement(t):
					base.decrement(t)

				probs = [ttable[w].prob(t, base.prob(t, uniform_tgt_word)) for w in src]
				a = mult(probs)
			s = src[a]
			if ttable[s].increment(t, base.prob(t, uniform_tgt_word)):
				base.increment(t, uniform_tgt_word)
			alignments[i][n] = a

	if sample == 30:
		base.resample_hyperparameters()
		tpr.resample_hyperparameters()

for s, src_id in bitext.src_dict.iteritems():
	for t, tgt_id in [(bitext.convert_tgt(tgt_id), tgt_id) for tgt_id in ttable[src_id].keys()]:
		print '%s\t%s\t%02f' % (s, t, ttable[src_id].prob(tgt_id, base.prob(tgt_id, uniform_tgt_word)))

print base.strength(), base.discount()
print ttable[0].strength(), ttable[0].discount()
print ttable[1].strength(), ttable[1].discount()
