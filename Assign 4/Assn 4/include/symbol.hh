#ifndef SYMBOL_HH
#define SYMBOL_HH
#include <bits/stdc++.h>
#include <set>
#include <string>
using namespace std;
#include "ast.hh"

// Basic symbol table, just keeping track of prior existence and nothing else
struct SymbolTable
{
    std::set<std::string> table;

    bool contains(std::string key);
    void insert(std::string key);
};
struct SymbolTable1
{
    std::map<std::string, std::pair<long long,long long>> table; // value,type

    bool contains(std::string key);
    void insert(std::string key, std::pair<long long,long long> val);
    std::pair<long long,long long> value(std::string key);
};


// new symbol table 
struct SymbolTable2
{
    std::map<long long, std::map<std::string, long long>> scope;
    long long curr = 0;
    bool contains(std::string key);
    void insert(std::string key, long long value);
    void update(std::string key, long long value);
    long long get(std::string key);
    void dec();
    void inc();
};

#endif