#pragma once

#include <math.h>
#include <float.h>

//#define ssize_t  __int64

typedef __int64             int64_t;    // Define it from MSVC's internal type
typedef __int32             int32_t;    
typedef __int16             int16_t;    
typedef __int8              int8_t;    

typedef unsigned __int64    uint64_t;
typedef unsigned __int32    uint32_t;
typedef unsigned __int16    uint16_t;
typedef unsigned __int8     uint8_t;

typedef uint32_t            mode_t;

#define isnan( x )          _isnan( x )

#ifndef INT64_C
# define INT64_C(x) x##i64
#endif

#ifndef UINT64_C
# define UINT64_C(x) x##ui64
#endif

#ifndef INT64_MAX
#define INT64_MAX INT64_C(9223372036854775807)
#endif

__inline int truncf( float flt )
{
    return (int)floor( flt );
}

__inline long int lrint (double flt)
{  
    int intgr;  
    _asm  
    {      
        fld flt      
        fistp intgr  
    };  

    return intgr;
}

__inline long int lrintf (float flt)
{   
    int intgr;   
    _asm  
    {    
        fld flt    
        fistp intgr  
    }; 

    return intgr;
}

