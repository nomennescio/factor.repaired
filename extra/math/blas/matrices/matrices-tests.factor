USING: kernel math.blas.matrices math.blas.vectors
sequences tools.test ;

! clone

{ Smatrix{
    { 1.0 2.0 3.0 }
    { 4.0 5.0 6.0 }
    { 7.0 8.0 9.0 }
} } [
    Smatrix{
        { 1.0 2.0 3.0 }
        { 4.0 5.0 6.0 }
        { 7.0 8.0 9.0 }
    } clone
] unit-test
{ f } [
    Smatrix{
        { 1.0 2.0 3.0 }
        { 4.0 5.0 6.0 }
        { 7.0 8.0 9.0 }
    } dup clone eq?
] unit-test

{ Dmatrix{
    { 1.0 2.0 3.0 }
    { 4.0 5.0 6.0 }
    { 7.0 8.0 9.0 }
} } [
    Dmatrix{
        { 1.0 2.0 3.0 }
        { 4.0 5.0 6.0 }
        { 7.0 8.0 9.0 }
    } clone
] unit-test
{ f } [
    Dmatrix{
        { 1.0 2.0 3.0 }
        { 4.0 5.0 6.0 }
        { 7.0 8.0 9.0 }
    } dup clone eq?
] unit-test

{ Cmatrix{
    { C{ 1.0 1.0 } 2.0          3.0          }
    { 4.0          C{ 5.0 2.0 } 6.0          }
    { 7.0          8.0          C{ 9.0 3.0 } }
} } [
    Cmatrix{
        { C{ 1.0 1.0 } 2.0          3.0          }
        { 4.0          C{ 5.0 2.0 } 6.0          }
        { 7.0          8.0          C{ 9.0 3.0 } }
    } clone
] unit-test
{ f } [
    Cmatrix{
        { C{ 1.0 1.0 } 2.0          3.0          }
        { 4.0          C{ 5.0 2.0 } 6.0          }
        { 7.0          8.0          C{ 9.0 3.0 } }
    } dup clone eq?
] unit-test

{ Zmatrix{
    { C{ 1.0 1.0 } 2.0          3.0          }
    { 4.0          C{ 5.0 2.0 } 6.0          }
    { 7.0          8.0          C{ 9.0 3.0 } }
} } [
    Zmatrix{
        { C{ 1.0 1.0 } 2.0          3.0          }
        { 4.0          C{ 5.0 2.0 } 6.0          }
        { 7.0          8.0          C{ 9.0 3.0 } }
    } clone
] unit-test
{ f } [
    Zmatrix{
        { C{ 1.0 1.0 } 2.0          3.0          }
        { 4.0          C{ 5.0 2.0 } 6.0          }
        { 7.0          8.0          C{ 9.0 3.0 } }
    } dup clone eq?
] unit-test

! M.V

{ Svector{ 3.0 1.0 6.0 } } [
    Smatrix{
        {  0.0 1.0 0.0 1.0 }
        { -1.0 0.0 0.0 2.0 }
        {  0.0 0.0 1.0 3.0 }
    }
    Svector{ 1.0 2.0 3.0 1.0 }
    M.V
] unit-test
{ Svector{ -2.0 1.0 3.0 14.0 } } [
    Smatrix{
        {  0.0 1.0 0.0 1.0 }
        { -1.0 0.0 0.0 2.0 }
        {  0.0 0.0 1.0 3.0 }
    } Mtranspose
    Svector{ 1.0 2.0 3.0 }
    M.V
] unit-test

{ Dvector{ 3.0 1.0 6.0 } } [
    Dmatrix{
        {  0.0 1.0 0.0 1.0 }
        { -1.0 0.0 0.0 2.0 }
        {  0.0 0.0 1.0 3.0 }
    }
    Dvector{ 1.0 2.0 3.0 1.0 }
    M.V
] unit-test
{ Dvector{ -2.0 1.0 3.0 14.0 } } [
    Dmatrix{
        {  0.0 1.0 0.0 1.0 }
        { -1.0 0.0 0.0 2.0 }
        {  0.0 0.0 1.0 3.0 }
    } Mtranspose
    Dvector{ 1.0 2.0 3.0 }
    M.V
] unit-test

{ Cvector{ 3.0 C{ 1.0 2.0 } 6.0 } } [
    Cmatrix{
        {  0.0 1.0          0.0 1.0 }
        { -1.0 C{ 0.0 1.0 } 0.0 2.0 }
        {  0.0 0.0          1.0 3.0 }
    }
    Cvector{ 1.0 2.0 3.0 1.0 }
    M.V
] unit-test
{ Cvector{ -2.0 C{ 1.0 2.0 } 3.0 14.0 } } [
    Cmatrix{
        {  0.0 1.0          0.0 1.0 }
        { -1.0 C{ 0.0 1.0 } 0.0 2.0 }
        {  0.0 0.0          1.0 3.0 }
    } Mtranspose
    Cvector{ 1.0 2.0 3.0 }
    M.V
] unit-test

{ Zvector{ 3.0 C{ 1.0 2.0 } 6.0 } } [
    Zmatrix{
        {  0.0 1.0          0.0 1.0 }
        { -1.0 C{ 0.0 1.0 } 0.0 2.0 }
        {  0.0 0.0          1.0 3.0 }
    }
    Zvector{ 1.0 2.0 3.0 1.0 }
    M.V
] unit-test
{ Zvector{ -2.0 C{ 1.0 2.0 } 3.0 14.0 } } [
    Zmatrix{
        {  0.0 1.0          0.0 1.0 }
        { -1.0 C{ 0.0 1.0 } 0.0 2.0 }
        {  0.0 0.0          1.0 3.0 }
    } Mtranspose
    Zvector{ 1.0 2.0 3.0 }
    M.V
] unit-test

! V(*)

{ Smatrix{
    { 1.0 2.0 3.0  4.0 }
    { 2.0 4.0 6.0  8.0 }
    { 3.0 6.0 9.0 12.0 }
} } [
    Svector{ 1.0 2.0 3.0 } Svector{ 1.0 2.0 3.0 4.0 } V(*)
] unit-test

{ Dmatrix{
    { 1.0 2.0 3.0  4.0 }
    { 2.0 4.0 6.0  8.0 }
    { 3.0 6.0 9.0 12.0 }
} } [
    Dvector{ 1.0 2.0 3.0 } Dvector{ 1.0 2.0 3.0 4.0 } V(*)
] unit-test

{ Cmatrix{
    { 1.0          2.0          C{ 3.0 -3.0 } 4.0            }
    { 2.0          4.0          C{ 6.0 -6.0 } 8.0            }
    { C{ 3.0 3.0 } C{ 6.0 6.0 } 18.0          C{ 12.0 12.0 } }
} } [
    Cvector{ 1.0 2.0 C{ 3.0 3.0 } } Cvector{ 1.0 2.0 C{ 3.0 -3.0 } 4.0 } V(*)
] unit-test

{ Zmatrix{
    { 1.0          2.0          C{ 3.0 -3.0 } 4.0            }
    { 2.0          4.0          C{ 6.0 -6.0 } 8.0            }
    { C{ 3.0 3.0 } C{ 6.0 6.0 } 18.0          C{ 12.0 12.0 } }
} } [
    Zvector{ 1.0 2.0 C{ 3.0 3.0 } } Zvector{ 1.0 2.0 C{ 3.0 -3.0 } 4.0 } V(*)
] unit-test

! M.

{ Smatrix{
    { 1.0 0.0  0.0 4.0  0.0 }
    { 0.0 0.0 -3.0 0.0  0.0 }
    { 0.0 4.0  0.0 0.0 10.0 }
    { 0.0 0.0  0.0 0.0  0.0 }
} } [
    Smatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Smatrix{
        { 1.0 0.0 0.0 4.0 0.0 }
        { 0.0 2.0 0.0 0.0 5.0 }
        { 0.0 0.0 3.0 0.0 0.0 }
    } M.
] unit-test

{ Smatrix{
    { 1.0  0.0  0.0 0.0 }
    { 0.0  0.0  4.0 0.0 }
    { 0.0 -3.0  0.0 0.0 }
    { 4.0  0.0  0.0 0.0 }
    { 0.0  0.0 10.0 0.0 }
} } [
    Smatrix{
        { 1.0 0.0 0.0 4.0 0.0 }
        { 0.0 2.0 0.0 0.0 5.0 }
        { 0.0 0.0 3.0 0.0 0.0 }
    } Mtranspose Smatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Mtranspose M.
] unit-test

{ Dmatrix{
    { 1.0 0.0  0.0 4.0  0.0 }
    { 0.0 0.0 -3.0 0.0  0.0 }
    { 0.0 4.0  0.0 0.0 10.0 }
    { 0.0 0.0  0.0 0.0  0.0 }
} } [
    Dmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Dmatrix{
        { 1.0 0.0 0.0 4.0 0.0 }
        { 0.0 2.0 0.0 0.0 5.0 }
        { 0.0 0.0 3.0 0.0 0.0 }
    } M.
] unit-test

{ Dmatrix{
    { 1.0  0.0  0.0 0.0 }
    { 0.0  0.0  4.0 0.0 }
    { 0.0 -3.0  0.0 0.0 }
    { 4.0  0.0  0.0 0.0 }
    { 0.0  0.0 10.0 0.0 }
} } [
    Dmatrix{
        { 1.0 0.0 0.0 4.0 0.0 }
        { 0.0 2.0 0.0 0.0 5.0 }
        { 0.0 0.0 3.0 0.0 0.0 }
    } Mtranspose Dmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Mtranspose M.
] unit-test

{ Cmatrix{
    { 1.0 0.0            0.0 4.0  0.0 }
    { 0.0 0.0           -3.0 0.0  0.0 }
    { 0.0 C{ 4.0 -4.0 }  0.0 0.0 10.0 }
    { 0.0 0.0            0.0 0.0  0.0 }
} } [
    Cmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Cmatrix{
        { 1.0 0.0           0.0 4.0 0.0 }
        { 0.0 C{ 2.0 -2.0 } 0.0 0.0 5.0 }
        { 0.0 0.0           3.0 0.0 0.0 }
    } M.
] unit-test

{ Cmatrix{
    { 1.0  0.0  0.0          0.0 }
    { 0.0  0.0 C{ 4.0 -4.0 } 0.0 }
    { 0.0 -3.0  0.0          0.0 }
    { 4.0  0.0  0.0          0.0 }
    { 0.0  0.0 10.0          0.0 }
} } [
    Cmatrix{
        { 1.0 0.0           0.0 4.0 0.0 }
        { 0.0 C{ 2.0 -2.0 } 0.0 0.0 5.0 }
        { 0.0 0.0           3.0 0.0 0.0 }
    } Mtranspose Cmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Mtranspose M.
] unit-test

{ Zmatrix{
    { 1.0 0.0            0.0 4.0  0.0 }
    { 0.0 0.0           -3.0 0.0  0.0 }
    { 0.0 C{ 4.0 -4.0 }  0.0 0.0 10.0 }
    { 0.0 0.0            0.0 0.0  0.0 }
} } [
    Zmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Zmatrix{
        { 1.0 0.0           0.0 4.0 0.0 }
        { 0.0 C{ 2.0 -2.0 } 0.0 0.0 5.0 }
        { 0.0 0.0           3.0 0.0 0.0 }
    } M.
] unit-test

{ Zmatrix{
    { 1.0  0.0  0.0          0.0 }
    { 0.0  0.0 C{ 4.0 -4.0 } 0.0 }
    { 0.0 -3.0  0.0          0.0 }
    { 4.0  0.0  0.0          0.0 }
    { 0.0  0.0 10.0          0.0 }
} } [
    Zmatrix{
        { 1.0 0.0           0.0 4.0 0.0 }
        { 0.0 C{ 2.0 -2.0 } 0.0 0.0 5.0 }
        { 0.0 0.0           3.0 0.0 0.0 }
    } Mtranspose Zmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Mtranspose M.
] unit-test

! n*M

{ Smatrix{
    { 2.0 0.0 }
    { 0.0 2.0 }
} } [
    2.0 Smatrix{
        { 1.0 0.0 }
        { 0.0 1.0 }
    } n*M
] unit-test

{ Dmatrix{
    { 2.0 0.0 }
    { 0.0 2.0 }
} } [
    2.0 Dmatrix{
        { 1.0 0.0 }
        { 0.0 1.0 }
    } n*M
] unit-test

{ Cmatrix{
    { C{ 2.0 1.0 } 0.0           }
    { 0.0          C{ -1.0 2.0 } }
} } [
    C{ 2.0 1.0 } Cmatrix{
        { 1.0 0.0          }
        { 0.0 C{ 0.0 1.0 } }
    } n*M
] unit-test

{ Zmatrix{
    { C{ 2.0 1.0 } 0.0           }
    { 0.0          C{ -1.0 2.0 } }
} } [
    C{ 2.0 1.0 } Zmatrix{
        { 1.0 0.0          }
        { 0.0 C{ 0.0 1.0 } }
    } n*M
] unit-test

! Mrows, Mcols

{ Svector{ 3.0 3.0 3.0 } } [
    2 Smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mcols nth
] unit-test
{ Svector{ 3.0 2.0 3.0 4.0 } } [
    2 Smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mrows nth
] unit-test
{ 3 } [
    Smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mrows length
] unit-test
{ 4 } [
    Smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mcols length
] unit-test
{ Svector{ 3.0 3.0 3.0 } } [
    2 Smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mrows nth
] unit-test
{ Svector{ 3.0 2.0 3.0 4.0 } } [
    2 Smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mcols nth
] unit-test
{ 3 } [
    Smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mcols length
] unit-test
{ 4 } [
    Smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mrows length
] unit-test

{ Dvector{ 3.0 3.0 3.0 } } [
    2 Dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mcols nth
] unit-test
{ Dvector{ 3.0 2.0 3.0 4.0 } } [
    2 Dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mrows nth
] unit-test
{ 3 } [
    Dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mrows length
] unit-test
{ 4 } [
    Dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mcols length
] unit-test
{ Dvector{ 3.0 3.0 3.0 } } [
    2 Dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mrows nth
] unit-test
{ Dvector{ 3.0 2.0 3.0 4.0 } } [
    2 Dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mcols nth
] unit-test
{ 3 } [
    Dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mcols length
] unit-test
{ 4 } [
    Dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mrows length
] unit-test

{ Cvector{ C{ 3.0 1.0 } C{ 3.0 2.0 } C{ 3.0 3.0 } } } [
    2 Cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mcols nth
] unit-test
{ Cvector{ C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } } } [
    2 Cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mrows nth
] unit-test
{ 3 } [
    Cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mrows length
] unit-test
{ 4 } [
    Cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mcols length
] unit-test
{ Cvector{ C{ 3.0 1.0 } C{ 3.0 2.0 } C{ 3.0 3.0 } } } [
    2 Cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mrows nth
] unit-test
{ Cvector{ C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } } } [
    2 Cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mcols nth
] unit-test
{ 3 } [
    Cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mcols length
] unit-test
{ 4 } [
    Cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mrows length
] unit-test

{ Zvector{ C{ 3.0 1.0 } C{ 3.0 2.0 } C{ 3.0 3.0 } } } [
    2 Zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mcols nth
] unit-test
{ Zvector{ C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } } } [
    2 Zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mrows nth
] unit-test
{ 3 } [
    Zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mrows length
] unit-test
{ 4 } [
    Zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mcols length
] unit-test
{ Zvector{ C{ 3.0 1.0 } C{ 3.0 2.0 } C{ 3.0 3.0 } } } [
    2 Zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mrows nth
] unit-test
{ Zvector{ C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } } } [
    2 Zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mcols nth
] unit-test
{ 3 } [
    Zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mcols length
] unit-test
{ 4 } [
    Zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mrows length
] unit-test

! Msub

{ Smatrix{
    { 3.0 2.0 1.0 }
    { 0.0 1.0 0.0 }
} } [
    Smatrix{
        { 0.0 1.0 2.0 3.0 2.0 }
        { 1.0 0.0 3.0 2.0 1.0 }
        { 2.0 3.0 0.0 1.0 0.0 }
    } 1 2 2 3 Msub
] unit-test

{ Smatrix{
    { 3.0 0.0 }
    { 2.0 1.0 }
    { 1.0 0.0 }
} } [
    Smatrix{
        { 0.0 1.0 2.0 3.0 2.0 }
        { 1.0 0.0 3.0 2.0 1.0 }
        { 2.0 3.0 0.0 1.0 0.0 }
    } Mtranspose 2 1 3 2 Msub
] unit-test

{ Dmatrix{
    { 3.0 2.0 1.0 }
    { 0.0 1.0 0.0 }
} } [
    Dmatrix{
        { 0.0 1.0 2.0 3.0 2.0 }
        { 1.0 0.0 3.0 2.0 1.0 }
        { 2.0 3.0 0.0 1.0 0.0 }
    } 1 2 2 3 Msub
] unit-test

{ Dmatrix{
    { 3.0 0.0 }
    { 2.0 1.0 }
    { 1.0 0.0 }
} } [
    Dmatrix{
        { 0.0 1.0 2.0 3.0 2.0 }
        { 1.0 0.0 3.0 2.0 1.0 }
        { 2.0 3.0 0.0 1.0 0.0 }
    } Mtranspose 2 1 3 2 Msub
] unit-test

{ Cmatrix{
    { C{ 3.0 3.0 } 2.0 1.0 }
    { 0.0          1.0 0.0 }
} } [
    Cmatrix{
        { 0.0 1.0 2.0          3.0 2.0 }
        { 1.0 0.0 C{ 3.0 3.0 } 2.0 1.0 }
        { 2.0 3.0 0.0          1.0 0.0 }
    } 1 2 2 3 Msub
] unit-test

{ Cmatrix{
    { C{ 3.0 3.0 } 0.0 }
    { 2.0          1.0 }
    { 1.0          0.0 }
} } [
    Cmatrix{
        { 0.0 1.0 2.0          3.0 2.0 }
        { 1.0 0.0 C{ 3.0 3.0 } 2.0 1.0 }
        { 2.0 3.0 0.0          1.0 0.0 }
    } Mtranspose 2 1 3 2 Msub
] unit-test

{ Zmatrix{
    { C{ 3.0 3.0 } 2.0 1.0 }
    { 0.0          1.0 0.0 }
} } [
    Zmatrix{
        { 0.0 1.0 2.0          3.0 2.0 }
        { 1.0 0.0 C{ 3.0 3.0 } 2.0 1.0 }
        { 2.0 3.0 0.0          1.0 0.0 }
    } 1 2 2 3 Msub
] unit-test

{ Zmatrix{
    { C{ 3.0 3.0 } 0.0 }
    { 2.0          1.0 }
    { 1.0          0.0 }
} } [
    Zmatrix{
        { 0.0 1.0 2.0          3.0 2.0 }
        { 1.0 0.0 C{ 3.0 3.0 } 2.0 1.0 }
        { 2.0 3.0 0.0          1.0 0.0 }
    } Mtranspose 2 1 3 2 Msub
] unit-test

! Bugfix: blas-matrix-base did not handle `f smatrix{ } equal?`
{ f } [
    f smatrix{
        svector{ 1.0 2.0 3.0 4.0 }
        svector{ 2.0 2.0 3.0 4.0 }
        svector{ 3.0 2.0 3.0 4.0 }
    } equal?
] unit-test