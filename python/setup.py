from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import re

ext_modules = [
  Extension(name='cpyp',
            sources=['cpyp.pyx'],
            language='c++',
            extra_compile_args=re.findall('-[^\s]+', '-std=c++11'))
]

setup(
  ext_modules = ext_modules,
  cmdclass = {'build_ext': build_ext}
)
