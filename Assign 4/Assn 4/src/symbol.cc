#include "symbol.hh"

bool SymbolTable::contains(std::string key)
{
    return table.find(key) 
    != table.end();
}

void SymbolTable::insert(std::string key)
{
    table.insert(key);
}

bool SymbolTable1::contains(std::string key)
{
    return table.find(key) 
    != table.end();
}

std::pair<long long, long long> SymbolTable1::value(std::string key)
{
    return table[key];
}

void SymbolTable1::insert(std::string key, std::pair<long long, long long> val)
{
    table[key] = val;
}

bool SymbolTable2::contains(std::string key)
{
    return scope[curr].find(key)
     != scope[curr].end();
}
long long SymbolTable2::get(std::string key)
{
    long long temp = curr;
    while (temp >= 0)
    {
        if (scope[temp].find(key) 
        != scope[temp].end())
            return scope[temp][key];
        temp--;
    }
    return 222;
}
void SymbolTable2::insert(std::string key, long long value)
{
    scope[curr][key] = value;
    return;
}
void SymbolTable2::dec()
{
    scope.erase(curr);
    curr--;
}
void SymbolTable2::inc()
{
    curr++;
}

void SymbolTable2::update(std::string key, long long value)
{
    long long temp = curr;
    if (scope[curr].find(key) 
    != scope[temp].end())
    {
        scope[temp][key] = value;
        
        return;
    }
    while (temp >= 0)
    {
        if (scope[temp].find(key) 
        != scope[temp].end())
        {
            scope[temp][key] = value;

            return;
        }
        temp--;
    }
    return;
}