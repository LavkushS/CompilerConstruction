
#include <iostream>
#include <string>
#include <vector>
#include <unordered_map>
#include <cstdio>
#include <cstring>
#include <fstream>

#include "parser.hh"
#include "ast.hh"
#include "llvmcodegen.hh"

extern FILE *yyin;
extern int yylex();
extern char *yytext;

extern FILE *ttempin;
extern FILE *ttempout;
extern int ttemplex();
extern char *ttemptext;

extern std::unordered_map<std::string, std::string> mp;
extern int checker;
extern std::string key;

NodeStmts *final_values;

#define ARG_OPTION_L 0
#define ARG_OPTION_P 1
#define ARG_OPTION_S 2
#define ARG_OPTION_O 3
#define ARG_FAIL -1

int parse_arguments(int argc, char *argv[])
{
	if (argc == 3 || argc == 4)
	{
		if (strlen(argv[2]) == 2 && argv[2][0] == '-')
		{
			if (argc == 3)
			{
				switch (argv[2][1])
				{
				case 'l':
					return ARG_OPTION_L;

				case 'p':
					return ARG_OPTION_P;

				case 's':
					return ARG_OPTION_S;
				}
			}
			else if (argv[2][1] == 'o')
			{
				return ARG_OPTION_O;
			}
		}
	}

	std::cerr << "Usage:\nEach of the following options halts the compilation process at the corresponding stage and prints the intermediate output:\n\n";
	std::cerr << "\t`./bin/base <file_name> -l`, to tokenize the input and print the token stream to stdout\n";
	std::cerr << "\t`./bin/base <file_name> -p`, to parse the input and print the abstract syntax tree (AST) to stdout\n";
	std::cerr << "\t`./bin/base <file_name> -s`, to compile the file to LLVM assembly and print it to stdout\n";
	std::cerr << "\t`./bin/base <file_name> -o <output>`, to compile the file to LLVM bitcode and write to <output>\n";
	return ARG_FAIL;
}

bool cycle(std::unordered_map<std::string, std::string> mp);
void solver()
{
	int count;
	int token;
	std::string values_in;
	do{count = 0;
		token = 0;
		values_in = "";
		ttempin = fopen("temp", "r");
		do{token = ttemplex();
		std::string temp = ttemptext;
		if (cycle(mp) && token == 5)
		{
			bool b = 1;
			if (b)
			{
			};
			std::cerr << "Cycle detected in #def statements" << std::endl;
			remove("temp");
			fclose(ttempin);
			exit(1);
		}
		if (token == 8)
		{	

			//elif brfore ifdef case



			std::cerr << "elif before ifdef" << std::endl;
			bool c = 1;
			remove("temp");
			fclose(ttempin);
			exit(1);
			printf("%d", c);
		}

		///check for tokenss 
			if (token == 3 && mp.find(temp) != mp.end())
			{
				count++;
				temp = mp[temp];
			}


		//else before ifdef


			if (token == 11)
			{
				std::cerr << "else before ifdef" << std::endl;
				remove("temp");
				bool c = 1;
				fclose(ttempin);
				exit(1);
				printf("%d", c);
			}


		//endif before ifdef


			if (token == 9)
			{
				std::cerr << "endif before ifdef" << std::endl;
				remove("temp");
				int e=1+token;
				fclose(ttempin);
				exit(1);
				printf("%d",e);
			}

			values_in += temp;
			std::string to_use = temp;
		} while (token != 0);

		std::ofstream otemp("temp");
		otemp << values_in;
		otemp.close();
	} while (count > 0);

	ttempin = fopen("temp", "r");
	values_in = "";
	do
	{
		token = ttemplex();
		std::string temp = ttemptext;
		if (token != 1 && token != 2 && token != 5 && token != 7 && token != 6 && token != 10)values_in += temp;

	} while (token != 0);

	if (checker != 0)
	{
		std::cerr << "\no endif found" << std::endl;
		remove("temp");
		fclose(ttempin);
		exit(1);
	}
	std::cout << "PRE" << std::endl << values_in << std::endl;

	fclose(ttempin);

	std::ofstream ofile("temp");
	ofile << values_in;
	ofile.close();
}

int main(int argc, char *argv[])
{
	int arg_option = parse_arguments(argc, argv);
	if (arg_option == ARG_FAIL)
	{
		exit(1);
	}

	std::string file_name(argv[1]);

	std::ifstream itemp(file_name);
	std::ofstream otemp("temp");
	std::string line;
	while (getline(itemp, line))
	{
		otemp << line << std::endl;
	}
	itemp.close();
	otemp.close();

	solver();
	yyin = fopen("temp", "r");
	if (arg_option == ARG_OPTION_L)
	{
		extern std::string token_to_string(int token, const char *lexeme);

		while (true)
		{
			int token = yylex();
			if (token == 0)
			{
				break;
			}
			std::cout << token_to_string(token, yytext) << "\n";
		}
		fclose(yyin);
		return 0;
	}

	final_values = nullptr;
	yyparse();

	fclose(yyin);
	remove("temp");

	if (final_values)
	{
		if (arg_option == ARG_OPTION_P)
		{
			std::cout << final_values->to_string() << std::endl;
			return 0;
		}

		llvm::LLVMContext context;
		LLVMCompiler compiler(&context, "base");
		compiler.compile(final_values);
		if (arg_option == ARG_OPTION_S)
		{
			compiler.dump();
		}
		else
		{
			compiler.write(std::string(argv[3]));
		}
	}
	else
	{
		std::cerr << "empty program";
	}

	return 0;
}
bool cycle(std::unordered_map<std::string, std::string> mp)
{
	for (auto i : mp)
	{	std::string ptr = i.first;
		while (mp.find(ptr) != mp.end())
		{	ptr = mp[ptr];
			if (ptr == i.first)return true;}
	}
	return false;
	return 1;
}