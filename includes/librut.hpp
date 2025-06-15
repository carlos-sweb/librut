#include <string>
#include <vector>
#include "absl/strings/str_join.h"
#include "absl/strings/str_split.h"
using namespace std;
using namespace absl;
namespace ppRut{
	class rut{
		private:
			string body="";
			string digitS="";
			int digitN=-1;
			int total = 0;
			int calculate();
			string numberToDigitV();
		public:	
		rut(string rutToParse);
		bool checkDigit(string localDigit);
		bool checkDigit();
		string format(string separate_miles=".",string separate_digit="-");
		string getDigit();
	};
}