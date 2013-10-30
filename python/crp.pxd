from libc.stdint cimport uint32_t
from libcpp.pair cimport pair

cdef extern from "<iostream>" namespace "std":
  cdef cppclass ostream:
    pass

cdef extern from "<unordered_map>" namespace "std":
  cdef cppclass unordered_map[KeyType, ValueType]:
    cppclass const_iterator:
      const_iterator() 
      const_iterator& operator++()
      pair[KeyType, ValueType] operator*()
      bint operator!=(const_iterator&)

cdef extern from "../cpyp/random.h" namespace "cpyp":
  cdef cppclass MT19937:
    MT19937() except +
    MT19937(uint32_t)
    uint32_t GetTrulyRandomSeed()
  cdef double sample_uniform01 "cpyp::sample_uniform01<double, cpyp::MT19937>"(MT19937& eng)

cdef extern from "../cpyp/crp_table_manager.h" namespace "cpyp":
  cdef cppclass crp_table_manager "cpyp::crp_table_manager<1>":
    pass

ctypedef unordered_map[unsigned, crp_table_manager].const_iterator const_iterator

cdef extern from "../cpyp/crp.h" namespace "cpyp":
  cdef cppclass crp[Dish]:
    crp() except +
    crp(double disc, double strength) except +
    crp(double d_strength, d_beta, c_shape, c_rate, d = 0.8, c = 1.0)
    void check_hyperparameters()
    double discount() const
    double strength() const
    void set_hyperparameters(double d, double s)
    void set_discount(double d)
    void set_strength(double a)
    bint has_discount_prior() const
    bint has_strength_prior() const
    void clear()
    unsigned num_tables() const
    unsigned num_tables(const Dish& dish) const
    unsigned num_customers() const
    unsigned num_customers(const Dish& dish) const
    int increment "increment<double, cpyp::MT19937>"(const Dish& dish, const double& p0, MT19937& eng)
    int increment_no_base "increment_no_base<cpyp::MT19937>"(const Dish& dish, MT19937& eng, double* logq)
    int decrement "decrement<cpyp::MT19937>"(const Dish& dish, MT19937& eng, double* longq = nullptr)
    float prob "prob<double>"(const Dish& dish, const double& p0) const
    double log_likelihood() const
    void update_llh_add_customer_to_table_seating(unsigned n)
    void update_llh_remove_customer_from_table_seating(unsigned n)
    double log_likelihood(const double& discount, const double& strength) const
    void resample_hyperparameters "resample_hyperparameters<cpyp::MT19937>"(MT19937& eng, const unsigned nloop, const unsigned niterations)
    void print_out "print"(ostream* out) const
    const_iterator begin() const
    const_iterator end() const
    void swap(crp[Dish]& b)
    #void serialize(Archive& ar, const unsigned int version)

"""def getrand():
  cdef MT19937 eng
  print sample_uniform01(eng)
  print eng.GetTrulyRandomSeed()

def testcrp():
  cdef MT19937 eng
  cdef crp[unsigned] crp
  crp.increment(1, 0.1, eng)
  crp.increment(1, 0.1, eng)
  crp.increment(2, 0.1, eng)
  print crp.num_customers()
  print crp.prob(0, 0.1)
  print crp.prob(1, 0.1)
  print crp.prob(2, 0.1)"""
