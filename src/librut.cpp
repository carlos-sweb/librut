#include <librut.hpp>
#include <vector>
#include <sstream>

using namespace std;

namespace ppRut{
	
	inline vector<string> split(const string& str, char delimiter = '-') {
	    vector<string> tokens;
	    string token;
	    istringstream tokenStream(str);    
	    while (getline(tokenStream,token,delimiter)) {
	        if (!token.empty()){
	            tokens.push_back(token);
	        }
	    }    
    	return tokens;
	}

	rut::rut(const string &rutToParse,const string &digitS):rutRaw(rutToParse),digitS(digitS){parser();}
	rut::rut(const int &rutToParse):rutRaw(to_string(rutToParse)){parser();}
	rut::rut(const string &rutToParse):rutRaw(rutToParse){parser();}
	void rut::parser(){
		if(!rutRaw.empty()){							
			// Aqui podemos mejorar para aceptar un espacio vacio
			// 30.000.000 5 algo asi
			int multiplicador=2;
			//const vector<string> v = StrSplit(rutRaw, "-");
			const vector<string> v = split(rutRaw);
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
		string output = "";		
		int position_separate=0;
		for(int i = (body.size()-1);i>=0;i-- ){
			if(position_separate == 3){				
				output.insert(0,separate_miles);
				position_separate = 1;
			}else{
				position_separate++;
			}			
			output.insert(0,string(1,body.at(i)));
		}		
		output.append(separate_digit);
		output.append(numberToDigitV());
		return output;
	}
	string rut::getDigit() const { return numberToDigitV();}
}
