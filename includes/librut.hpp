#ifndef LIBRUT_HPP
#define LIBRUT_HPP

#if defined(__GNUC__) && __GNUC__ >= 4
    #define RUT_API __attribute__((visibility("default")))
#else
    #define RUT_API
#endif

#include <string>

using namespace std;

namespace ppRut{
	class RUT_API rut{
		private:
			// string 
			string rutRaw="",
			body="",
			digitS="",
			numberToDigitV() const;
			// int
			int digitN=-1,
			total = 0,
			calculate();
			// void
			void parser();
		public:	
			rut(const string&,const string&);
			rut(const string&);
			rut(const int&);
			bool checkDigit(const string&) const ;
			bool checkDigit() const;
			string format(const string &separate_miles=".",const string &separate_digit="-") const;
			string getDigit() const;
	};
}
#endif