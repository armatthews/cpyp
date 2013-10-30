cimport cython
cimport crp
cimport tied_parameter_resampler

ctypedef unsigned dish_type
ctypedef crp.crp[dish_type] crp_t

cdef class CRP:
	cdef crp_t* CRP
	cdef crp.MT19937 rng

	def __cinit__(self):
		self.CRP = new crp_t()

	def __dealloc__(self):	
		del self.CRP

	def discount(self):
		return self.CRP.discount()

	def strength(self):
		return self.CRP.strength()

	def set_hyperparameters(self, double d, double s):
		self.CRP.set_hyperparameters(d, s)

	def set_discount(self, double d):
		self.CRP.set_discount(d)

	def set_strength(self, double a):
		self.CRP.set_strength(a)

	def has_discount_prior(self):
		return self.CRP.has_discount_prior()

	def has_strength_prior(self):
		return self.CRP.has_strength_prior()

	def clear(self):
		self.CRP.clear()

	def num_tables(self, dish=None):
		return self.CRP.num_tables(dish) if dish is not None else self.CRP.num_tables()

	def num_customers(self, dish=None):
		return self.CRP.num_customers(dish) if dish is not None else self.CRP.num_customers()

	def increment(self, dish_type dish, double p0):
		return self.CRP.increment(dish, p0, self.rng)

	def increment_no_base(self, dish_type dish):
		cdef double logq = 0.0
		r = self.CRP.increment_no_base(dish, self.rng, &logq)
		return (r, logq)

	def decrement(self, dish_type dish):
		return self.CRP.decrement(dish, self.rng)

	def prob(self, dish_type dish, double p0):
		return self.CRP.prob(dish, p0)

	def log_likelihood(self, discount=None, strength=None):
		if discount is not None and strength is not None:
			return self.CRP.log_likelihood(discount, strength)
		else:
			return self.CRP.log_likelihood()

	def keys(self):
		used_keys = []
		cdef crp.const_iterator it = self.CRP.begin()
		while it != self.CRP.end():
			key = cython.operator.dereference(it).first
			used_keys.append(key)
			cython.operator.postincrement(it)
		return used_keys

	def resample_hyperparameters(self, unsigned nloop = 5, unsigned niterations = 10):
		self.CRP.resample_hyperparameters(self.rng, nloop, niterations)

cdef class TiedParameterResampler:
	cdef tied_parameter_resampler.tied_parameter_resampler[crp_t]* resampler
	cdef crp.MT19937 rng

	def __cinit__(self, double da, double db, double ss, double sr, double d = 0.5, double s = 1.0):
		self.resampler = new tied_parameter_resampler.tied_parameter_resampler[crp_t](da, db, ss, sr, d, s)

	def insert(self, CRP crp):
		self.resampler.insert(crp.CRP)

	def erase(self, CRP crp):
		self.resampler.erase(crp.CRP)

	def size(self):
		return self.resampler.size()

	def log_likelihood(self, d=None, s=None):
		if d is not None and s is not None:
			return self.resampler.log_likelihood(d, s)
		else:
			return self.resampler.log_likelihood()

	def resample_hyperparameters(self, unsigned nloop = 5, unsigned niterations = 10):
		self.resampler.resample_hyperparameters(self.rng, nloop, niterations)	
