#include "bool8_t/bool8_t.hpp"

#include <iostream>


int main()
{
	std::cout << "Size of the bool8_t class : " << sizeof(bool8_t) << " byte\n";

	// create an default instance. All flags is false
	bool8_t bool8;

	// change the flags
	bool8.flag0 = true;
	bool8.flag3 = true;

	// write the all flags using overloaded operator []
	std::cout << "bool8_t flags:\n";
	for (int i = 0; i < bool8.flagCount(); ++i)
		std::cout << i << ") " << bool8[i] << '\n';

	// set value for the all flags
	bool8 = false;
	if (!bool8)
		std::cout << "All flags of the bool8 is false\n";

	// inverse flags
	bool8.inverse();
	if (bool8)
		std::cout << "All flags of the bool8 is true";
}