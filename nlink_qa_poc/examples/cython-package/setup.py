from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy

extensions = [
    Extension(
        "nlink_data_marshal",
        ["src/nlink_data_marshal.pyx"],
        include_dirs=[numpy.get_include()],
        extra_compile_args=["-O3", "-fPIC"],
        extra_link_args=["-shared"],
    )
]

setup(
    name="nlink-data-marshal",
    version="1.1.0",
    description="NexusLink Zero-Overhead Data Marshalling for Python",
    author="OBINexus Engineering Team",
    author_email="engineering@obinexus.com",
    ext_modules=cythonize(
        extensions,
        compiler_directives={
            "language_level": "3",
            "boundscheck": False,
            "wraparound": False,
            "initializedcheck": False,
            "cdivision": True,
            "embedsignature": True,
        },
    ),
    zip_safe=False,
    packages=["nlink_marshal"],
    python_requires=">=3.8",
    install_requires=[
        "numpy>=1.19.0",
        "cython>=3.0.0",
    ],
)
