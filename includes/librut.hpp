#include <string>
#include <vector>
#include "absl/strings/str_join.h"
#include "absl/strings/str_split.h"
using namespace std;
using namespace absl;
namespace ppRut{
	class rut{
		private:
			string rutRaw="";
			string body="";
			string digitS="";
			int digitN=-1;
			int total = 0;
			int calculate();
			string numberToDigitV() const;
			void parser();
		public:	
			rut(const string&,const string&);
			rut(const string&);
			rut(const int&);
			bool checkDigit(const string&) const ;
			bool checkDigit() const;
			string format(const string &separate_miles=".",const string &separate_digit="-");
			string getDigit();
	};
}