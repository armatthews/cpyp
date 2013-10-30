from libc.stdint cimport uint32_t
cimport crp

ctypedef unsigned size_t

cdef extern from "../cpyp/tied_parameter_resampler.h" namespace "cpyp":
  cdef cppclass tied_parameter_resampler[CRP]:
    tied_parameter_resampler(double da, double db, double ss, double sr, double d, double s)
    void erase(CRP* crp)
    void insert(CRP* crp)
    size_t size() const
    double log_likelihood(double d, double s) const
    double log_likelihood() const
    void resample_hyperparameters "resample_hyperparameters<cpyp::MT19937>"(crp.MT19937& eng, const unsigned nloop, const unsigned niterations)
