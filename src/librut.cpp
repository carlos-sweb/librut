#include <string>
#include <librut.hpp>
#include <utility>
using namespace std;
using namespace absl;

namespace ppRut{
	rut::rut(const string &rutToParse,const string &digitS):rutRaw(std::move(rutToParse)),digitS(digitS){parser();}
	rut::rut(const int &rutToParse):rutRaw(to_string(rutToParse)){parser();}
	rut::rut(const string &rutToParse):rutRaw(rutToParse){parser();}
	void rut::parser(){
		if(!rutRaw.empty()){
			vector<string> v = StrSplit(rutRaw, "-");
			string bodyDirty = v.size() >= 1 ? v.at(0) : "";
			for(char c : bodyDirty ){if(isdigit(static_cast<unsigned char>(c))){body.push_back(c);}}			 
			if(v.size() >= 2){
				digitS	 = v.at(1);
			}
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