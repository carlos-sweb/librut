#include <string>
#include <librut.hpp>
#include <iostream>


using namespace std;
using namespace absl;

namespace ppRut{
	rut::rut(const string &rutToParse,const string &digitS):rutRaw(rutToParse),digitS(digitS){parser();}
	rut::rut(const int &rutToParse):rutRaw(to_string(rutToParse)){parser();}
	rut::rut(const string &rutToParse):rutRaw(rutToParse){parser();}
	void rut::parser(){
		if(!rutRaw.empty()){							
			// Aqui podemos mejorar para aceptar un espacio vacio
			// 30.000.000 5 algo asi
			int multiplicador=2;
			const vector<string> v = StrSplit(rutRaw, "-");
			if(v.size() >= 1){
				for(char c : v.at(0) ){
					if(isdigit(static_cast<unsigned char>(c))){
						body.push_back(c);
					}
				}	
			}			
			if(v.size() >= 2){
				digitS	 = v.at(1);
			}										
			for(int i = (body.length()-1); i >= 0;i--){
				if(isdigit(static_cast<unsigned char>(body.at(i)))){					
					total += ((body.at(i)-'0')*multiplicador);
					multiplicador = multiplicador == 7 ? 2 : ( multiplicador + 1 );
				}				
			}			
		}
		calculate();
	}
	bool rut::checkDigit(const string &localDigit) const {return (numberToDigitV() == localDigit);}
	bool rut::checkDigit() const {return (numberToDigitV() == digitS);}
	int rut::calculate(){
		digitN = 11-(total-((total/11)*11));
		return digitN;
	}
	string rut::numberToDigitV() const {
		return digitN == 11 ? "0" : ( digitN == 10 ? "k" : to_string(digitN) );
	}
	string rut::format(const string &separate_miles,const string &separate_digit) const {
		string output = "",
		TmpBody = "";
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
	string rut::getDigit() const { return numberToDigitV();}
}