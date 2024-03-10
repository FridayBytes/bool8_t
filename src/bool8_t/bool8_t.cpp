////////////////////////////////////////////////////////////
//
// bool8_t library
//
// This software is provided 'as-is', without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it freely,
// subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented;
//    you must not claim that you wrote the original software.
//    If you use this software in a product, an acknowledgment
//    in the product documentation would be appreciated but is not required.
//
// 2. Altered source versions must be plainly marked as such,
//    and must not be misrepresented as being the original software.
//
// 3. This notice may not be removed or altered from any source distribution.
//
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Headers
////////////////////////////////////////////////////////////
#include "bool8_t/bool8_t.hpp"


////////////////////////////////////////////////////////////
bool8_t::bool8_t(bool val) 
{
	flag0 = flag1 = flag2 = flag3 = flag4 = flag5 = flag6 = flag7 = val ? 1 : 0;
}


////////////////////////////////////////////////////////////
bool8_t &bool8_t::operator =(const bool8_t& right)
{
	flag0 = right.flag0;
	flag1 = right.flag1;
	flag2 = right.flag2;
	flag3 = right.flag3;
	flag4 = right.flag4;
	flag5 = right.flag5;
	flag6 = right.flag6;
	flag7 = right.flag7;

	return *this;
}


////////////////////////////////////////////////////////////
bool bool8_t::operator [](uint8_t index) const
{
	switch (index)
	{
	case 0:
		return flag0;
	case 1:
		return flag1;
	case 2:
		return flag2;
	case 3:
		return flag3;
	case 4:
		return flag4;
	case 5:
		return flag5;
	case 6:
		return flag6;
	case 7:
		return flag7;
	default:
		return false;
	}
}


////////////////////////////////////////////////////////////
bool8_t::operator bool()
{
	return (flag0 && flag1 && flag2 && flag3 && flag4 && flag5 && flag6 && flag7);
}


////////////////////////////////////////////////////////////
bool8_t bool8_t::operator !()
{
	bool8_t newInstance = *this;
	newInstance.inverse();

	return newInstance;
}


////////////////////////////////////////////////////////////
void bool8_t::inverse()
{
	flag0 = !flag0;
	flag1 = !flag1;
	flag2 = !flag2;
	flag3 = !flag3;
	flag4 = !flag4;
	flag5 = !flag5;
	flag6 = !flag6;
	flag7 = !flag7;
}


////////////////////////////////////////////////////////////
bool8_t_API bool operator==(const bool8_t& left, const bool8_t& right)
{
	return (left.flag0 == right.flag0) &&
		   (left.flag1 == right.flag1) &&
	       (left.flag2 == right.flag2) &&
		   (left.flag3 == right.flag3) &&
		   (left.flag4 == right.flag4) &&
   		   (left.flag5 == right.flag5) &&
		   (left.flag6 == right.flag6) &&
		   (left.flag7 == right.flag7);
}


////////////////////////////////////////////////////////////
bool8_t_API bool operator !=(const bool8_t& left, const bool8_t& right)
{
	return !operator==(left, right);
}
