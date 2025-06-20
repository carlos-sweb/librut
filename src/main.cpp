#include <fmt/base.h>
#include <fmt/format.h>
#include <fmt/ranges.h>
#include <string>
#include <vector>
#include "argh.h"
#include "librut.hpp"
using namespace std;
int main(int,char * argv[]){
    argh::parser cmdl(argv);
    if (cmdl({ "-p", "--parser" })){    	
    	ppRut::rut rut(cmdl({"-p","--parser"}).str());
    	auto digitCheck = cmdl({"--check-digit"}).str();    	
    	if(digitCheck!=NULL){
    		const vector<string> accept_digit = {"0","1","2","3","4","5","6","7","8","9","k"};
    		bool valid_digit =std::find(accept_digit.begin(),accept_digit.end(),digitCheck) != accept_digit.end();    		
    		bool check = rut.checkDigit(digitCheck);
    		if(!valid_digit){
    			fmt::print("Use a valid digit => {}\n"," 0-9 or \"k\" letter");
    		}
    		fmt::print("check digit => {}\n",(check ? "\033[32mOk\033[00m":digitCheck+" \033[31mError\033[00m"));
    	}

		if( !cmdl[{"--get-digit"}] ){
			auto separate_miles = !cmdl[{"--separate-miles"}] ? cmdl({"--separate-miles"}) ? cmdl({"--separate-miles"}).str() : "." : ".";			
			auto separate_digit = !cmdl[{"--separate-digit"}] ? cmdl({"--separate-digit"}) ?  cmdl({"--separate-digit"}).str() : "-" :"-";
			fmt::print("{}\n",rut.format(separate_miles,separate_digit));
		}else{			
			fmt::print("{}\n",rut.getDigit());
		}    	    	
    }else{    	
    	if(cmdl[{"--help","-h"}]){
    		fmt::print(" {}\n\n","Usage: rut [OPTIONS]");
    		fmt::print(" {}\n","Options:");
    		fmt::print(" {}\n","-p,--parser: <RUT>          string rut to check");
    		fmt::print(" {}\n","--check-digit:              digit to compare");
    		fmt::print(" {}\n","--format-separate-miles:    string to separate miles default .");
    		fmt::print(" {}\n","--format-separate-digit:    string to separate digit default -");
    		fmt::print(" {}\n","-v,--version:               show version");
    		fmt::print(" {}\n","");
    	} 
    	if(cmdl[{"--version","-v"}]){
    		fmt::print("Version {}\n","1.0.0");    		
    	}      	
    }   	
    return EXIT_SUCCESS;
}