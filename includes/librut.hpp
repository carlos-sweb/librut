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
			int calculate(){
			digitN = 11-(total-((total/11)*11)); 		
			return digitN;
			}
			string numberToDigitV(){
			return digitN == 11 ? "0" : ( digitN == 10 ? "k" : to_string(digitN) );		
			}
		public:	
		rut(string rutToParse=NULL){
			if(!rutToParse.empty()){
				vector<string> v = StrSplit(rutToParse, "-");			
				string bodyDirty = v.size() >= 1 ? v.at(0) : "";				
				for(char c : bodyDirty ){if(isdigit(static_cast<unsigned char>(c))){body.push_back(c);}}
				digitS = v.size() >= 2 ? v.at(1): "";				
				string TmpBody = body;
				reverse(TmpBody.begin(),TmpBody.end());
				int multiplicador=2;
				for(char c : TmpBody){
					if(isdigit(static_cast<unsigned char>(c))){
						int cInit = ( c-'0') * multiplicador;												
						total = (total+cInit);
						if(multiplicador==7){multiplicador=2;}else{multiplicador++;}
					}
				}
			}		
			calculate();		
		}
		
		bool checkDigit(string localDigit){
			return (numberToDigitV() == localDigit);
		}
		bool checkDigit(){
			return (numberToDigitV() == digitS);
		}
		string format(string separate_miles=".",string separate_digit="-"){
			string output = "";
			string TmpBody = "";
			int position_separate=0;
			for(int i = (body.size()-1);i>=0;i-- ){
				if(position_separate == 3){TmpBody.append(separate_miles);position_separate = 1;}else{position_separate++;}
				TmpBody.push_back(body.at(i));
			}
			reverse(TmpBody.begin(),TmpBody.end());						
			output.append(TmpBody);
			output.append(separate_digit);
			output.append(numberToDigitV());
			return output;
		}
		string getDigit(){
			return numberToDigitV();
		}
	};
}