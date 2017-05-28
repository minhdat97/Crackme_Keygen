#include<iostream>
#include<string>
#include<ctime>
#include<algorithm>
using namespace std;


static const char alphanum[] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz";

int stringLength = sizeof(alphanum) - 1;

// Random chuỗi kí tự
char genRandom()
{

	return alphanum[rand() % stringLength];
}

// Random số kí tự của user trong khoảng [5,10]
int Rand_Num()
{
	srand(static_cast<unsigned int>(time(NULL)));
	int a = rand() % 6 + 5;
	return a;
}

// Tạo serial
int Keygen(string user)
{
	int s = 0;
	for (size_t i = 0; i < user.size(); i++)
	{
		s += (user[i] - '0') + 48;
	}
	return s ^ 0x444c;
}


int main()
{
	do
	{
		srand(static_cast<unsigned int>(time(0)));
		string Str;
		unsigned int a = Rand_Num();
		for (unsigned int i = 0; i < a; ++i)
		{
			Str += genRandom();
		}
		cout << "\nUsername: " << Str << endl;
		transform(Str.begin(), Str.end(), Str.begin(), ::toupper);
		cout << "Serial: " << Keygen(Str) << endl;
		cout << "Press Enter to generate other keys...";
	} while (cin.get() == '\n');
}