#include <stdio.h>
#include <string>
#include <vector>
#include "argh.h"
#include "librut.hpp"
using namespace std;
using namespace ppRut;
int main(int,char * argv[]){
    argh::parser cmdl(argv);
    if (cmdl({ "-p", "--parser" })){
    	rut rut(cmdl({"-p","--parser"}).str());
    	string digitCheck = cmdl({"--check-digit"}).str();
    	if(!digitCheck.empty()){
    		const vector<string> accept_digit = {"0","1","2","3","4","5","6","7","8","9","k"};
    		bool valid_digit =std::find(accept_digit.begin(),accept_digit.end(),digitCheck) != accept_digit.end();    		
    		bool check = rut.checkDigit(digitCheck);
    		if(!valid_digit){    			
    			printf("Use a valid digit => 0-9 or \"k\" letter\n");
    		}    		
    		printf("Check digit => %s\n",string((check ? "\033[32mOk\033[00m" : digitCheck+" \033[31mError\033[00m")).c_str() );
    	}

		if(!cmdl[{"--get-digit"}]){
			auto separate_miles = !cmdl[{"--separate-miles"}] ? cmdl({"--separate-miles"}) ? cmdl({"--separate-miles"}).str() : "." : ".";
			auto separate_digit = !cmdl[{"--separate-digit"}] ? cmdl({"--separate-digit"}) ?  cmdl({"--separate-digit"}).str() : "-" :"-";
			printf("%s\n",rut.format(separate_miles,separate_digit).c_str());
		}else{
			printf("%s\n",rut.getDigit().c_str());			
		}    	    	
    }else{
    	if(cmdl[{"--help","-h"}]){
    		printf(" %s\n\n","Usage: rut [OPTIONS]");
    		printf(" %s\n","Options:");
    		printf(" %s\n","-p,--parser: <RUT>          string rut to check");    		
    		printf(" %s\n","--check-digit:              digit to compare");    		    		
    		printf(" %s\n","--format-separate-miles:    string to separate miles default .");    		
    		printf(" %s\n","--format-separate-digit:    string to separate digit default -");    		
    		printf(" %s\n","-v,--version:               show version");    		
    		printf(" %s\n","");
    	} 
    	if(cmdl[{"--version","-v"}]){
    		printf("Version \"1.0.0\"\n");
    	}      	
    }   	
    return EXIT_SUCCESS;
}