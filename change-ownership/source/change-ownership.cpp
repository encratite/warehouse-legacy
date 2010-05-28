#include <iostream>
#include <string>
#include <stdexcept>

#include <unistd.h>
#include <sys/types.h>

#include <pwd.h>
#include <grp.h>

namespace
{
	//this macro is specified by the build shell script
	std::string const permittedGroup = CHANGE_OWNERSHIP_GROUP;
}

void printUsage(char ** argv)
{
	std::cout << "Usage:" << std::endl;
	std::cout << argv[0] << " <user> <path>" << std::endl;
}

std::string getEffectiveUserName()
{
	uid_t effectiveUserId = geteuid();
	passwd * passwordData = getpwuid(effectiveUserId);
	if(passwordData == NULL)
		throw std::runtime_error("Unable to retrieve effective user name");
	
	return passwordData->pw_name;
}

void changeOwnership(std::string const & user, std::string const & userGroup, std::string const & path)
{
	if(getEffectiveUserName() != "root")
		throw std::runtime_error("You need to run this program with super user privileges");
		
	passwd * passwordData = getpwnam(user.c_str());
	if(passwordData == NULL)
		throw std::runtime_error("Unable to determine if user is in group");
	
	group * groupData = getgrnam(userGroup.c_str());
	if(groupData == NULL)
		throw std::runtime_error("Unable to retrieve group data");

	if(passwordData->pw_gid != groupData->gr_gid)
		throw std::runtime_error("This user is not a member of the permitted group");
	
	int result = chown(path.c_str(), passwordData->pw_uid, groupData->gr_gid);
	if(result == -1)
		throw std::runtime_error("Unable to change the ownership of the file in question");
}

int main(int argc, char ** argv)
{
	if(argc != 3)
	{
		printUsage(argv);
		return 1;
	}
	
	try
	{
		changeOwnership(argv[1], permittedGroup, argv[2]);
	}
	catch(std::runtime_error & exception)
	{
		std::cout << "An exception occured: " << exception.what() << std::endl;
		return 1;
	}
	
	return 0;
}
