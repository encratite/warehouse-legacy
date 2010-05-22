#include <iostream>
#include <istream>
#include <iterator>
#include <string>

#include <sys/types.h>

#include <unistd.h>
#include <pwd.h>
#include <shadow.h>

namespace mainResult
{
	enum
	{
		usernameAndPasswordMatch,
		usernameAndPasswordMismatch,
		error
	};
}

std::string readData()
{
	std::string output(getpass("Specify the user and the password to be checked (user:password): "));
	return output;
}

//returns false if the input was malformed
bool parseInput(std::string const & input, std::string & usernameOutput, std::string & passwordOutput)
{
	std::size_t separatorOffset = input.find(':');
	if(separatorOffset == std::string::npos)
		return false;
		
	usernameOutput = input.substr(0, separatorOffset);
	passwordOutput = input.substr(separatorOffset + 1);
	return true;
}

int performCheck(std::string const & username, std::string const & password)
{
	passwd * passwordData = getpwnam(username.c_str());
	if(passwordData == NULL)
	{
		std::cout << "No such user" << std::endl;
		return mainResult::error;
	}
	
	spwd * shadowData = getspnam(passwordData->pw_name);
	if(shadowData == NULL)
	{
		std::cout << "Unable to retrieve the password of user " << username << std::endl;
		return mainResult::error;
	}
	
	std::string encryptedSystemPassword(shadowData->sp_pwdp);
	std::string encryptedInputPassword = crypt(password.c_str(), encryptedSystemPassword.c_str());
	
	if(encryptedSystemPassword == encryptedInputPassword)
		return mainResult::usernameAndPasswordMatch;
	else
		return mainResult::usernameAndPasswordMismatch;
}

void printUsage(int argc, char ** argv)
{
	std::cout << "Usage:" << std::endl;
	std::cout << argv[0] << " - read user:password from stdin and check if the login is valid." << std::endl;
	std::cout << "Returns 0 when that is the case, 1 when they mismatch and 2 in case of an error." << std::endl;
}

int main(int argc, char ** argv)
{
	if(argc != 1)
	{
		printUsage(argc, argv);
		return mainResult::error;
	}
	
	std::string input = readData();
	
	std::string
		username,
		password;
		
	if(!parseInput(input, username, password))
	{
		std::cout << "Invalid input, expected user:password" << std::endl;
		return mainResult::error;
	}
	
	return performCheck(username, password);
}
