#!/bin/bash

#Display documentation of script for help option
if [ "$1" = "help" ]; then
	echo -e "Usage:		./stymphalian_birds language name [path] [-opt arg]\n"
	echo "'language'"
	echo -e "Supported languages: c[C], php[PHP], bash[BASH]\n"

	echo "'name'"
	echo "For bash[BASH], 'name' specifies the name of the .sh file that will be created. Only accepts [path] and no other options."
	echo "For all other languages, 'name' specifieds the name of the project directory that will be created"
	echo -e "(A directory will be created even if the language is not supported.)\n"

	echo "'path'"
	echo -e "File[s] will be created in the current directory unless a relative path is provided\n"

	echo "[-opt arg]"
	echo "-git link 	Clones repository from link to name (must be first option)"
	echo "-gitignore 	Creates a .gitignore file at the root of project folder"
	echo "-lib path 	Copies libary files into name/srcs/lib from relative path to src/lib folder"
	echo "-dir path 	Copies a directory from relative path to root of the project folder"
	echo " 		(Warning: if source directory already exists in project folder, files with the same name will be overwritten.)"
	echo "-author 	Creates a author file populated with name in the ENV variable USER"
	exit 1
fi

#Display usage and exit if minimum of arguments (2) not provided
if [ $# -lt 2 ]; then
	echo "Usage:		./stymphalian_birds language dir-name [-opt arg]"
	echo "For help: 	./stymphalian_birds help"
	exit 1
fi

#Save language and name
language="$1"; shift
name="$1"; shift

path="."
#Save path if provided
if [ $# -gt 0 ] && [ ${1:0:1} != "-" ]; then
	path="$1"
	#Check if path exists
	if [ ! -d "$path" ]; then
		echo "Invalid path, try again."
		exit 1
	fi
	shift
fi

#If language is bash[BASH], create .sh file and exit
if [ $language = "bash" ] || [ $language = "BASH" ]; then
	if [ -e "$path/$name".sh ]; then
		echo "$name.sh already exists."
		exit 1
	fi
	echo "#!/bin/bash" > $path/$name.sh
	chmod 755 $path/$name.sh
	exit 0
fi

#Exit if name directory already exists
if [ -e "$path/$name" ]; then
	echo "$name already exists."
	exit 1
fi

#Create directory regardless of language
#Clone from git repository if -git option specified
if [ "$1" = "-git" ]; then
	shift
	if [ $# -lt 0 ] || [ ${1:0:1} = '-' ]; then
		echo "Missing link to git repository, exiting."
		exit 1
	fi
	git clone "$1" $path/$name 2>/dev/null
	shift
	if [ ! -e "$path/$name" ]; then
		echo "An error occured, check your git link and try again."
		exit 1
	fi
else
	mkdir $path/$name 2>/dev/null
	if [ ! -e "$path/$name" ]; then
		echo "Invalid file name, try another one."
		exit 1
	fi
fi

#Create default package according to language
case $language in
	"c" | "C")
	mkdir -p $path/$name/src/lib
	echo "*.o" >> $path/$name/.gitignore
	echo "*.out" >> $path/$name/.gitignore
	if [ ! -e "$path/$name/author" ]; then
		if [ ! $USER ]; then
			touch $path/$name/author
		else
			echo $USER > $path/$name/author
		fi
	fi
	if [ ! -e "$path/$name/$name.h" ]; then
		upperName=$(echo "$name" | tr '[:lower:]' '[:upper:]')
		printf "#ifndef %s_H\n" "$upperName" >> $path/$name/$name.h
		printf "# define %s_H\n\n" "$upperName" >> $path/$name/$name.h
		echo "#endif" >> $path/$name/$name.h
	fi
	if [ ! -e "$path/$name/Makefile" ]; then
		echo "NAME = $name" >> $path/$name/Makefile
		echo "SRCS = \$(wildcard *.c)" >> $path/$name/Makefile
		echo "OFILES = \$(SRCS:.c=.o)" >> $path/$name/Makefile
		echo "LIBFT = src/lib/" >> $path/$name/Makefile
		echo -e "LFT = -L \$(LIBFT) -lft\n" >> $path/$name/Makefile
		echo -e "all: \$(NAME)\n" >> $path/$name/Makefile
		echo "\$(NAME):" >> $path/$name/Makefile
		echo -e "\tmake -C \$(LIBFT)" >> $path/$name/Makefile
		echo -e "\tgcc -Wall -Wextra -Werror \$(SRCS) \$(LFT) -o \$(NAME)\n" >> $path/$name/Makefile
		echo "clean:" >> $path/$name/Makefile
		echo -e "\tmake -C \$(LIBFT) clean" >> $path/$name/Makefile
		echo -e "\t/bin/rm -f \$(OFILES)\n" >> $path/$name/Makefile
		echo "fclean: clean" >> $path/$name/Makefile
		echo -e "\tmake -C \$(LIBFT) fclean" >> $path/$name/Makefile
		echo -e "\t/bin/rm -f \$(NAME)\n" >> $path/$name/Makefile
		echo "re: fclean all" >> $path/$name/Makefile
	fi
	;;
	"php" | "PHP")
	echo "<?php" > $path/$name/index.php
	;;
esac

#Loop through arguments for additional options
while [ $# -gt 0 ]; do
	case "$1" in
		"-gitignore")
		if [ ! -e .gitignore ]; then
			touch $path/$name/.gitignore
		fi
		;;
		"-lib")
		shift
		if [ $# -lt 1 ] || [ ${1:0:1} = "-" ]; then
			echo "Missing path for -lib, libary files not copied."
		else
			libPath="$1"
			if [ ! -d "$libPath" ]; then
				echo "Invalid path for -lib, libary files not copied."
			else
				if [ ! -d "$name/src/lib" ]; then
					mkdir -p $name/src/lib
				fi
				cp "$libPath"/* "$path/$name/src/lib"
			fi
		fi
		;;
		"-dir")
		shift
		if [  $# -lt 1 ] || [ ${1:0:1} = "-" ]; then
			echo "Missing path for -dir, directory not copied."
		else
			dirPath="$1"
			if [ ! -d "$dirPath" ]; then
				echo "Invalid path for -dir, directory not copied."
			else
				cp -R $dirPath $path/$name
			fi
		fi
		;;
		"-author")
			if [ $language != c ] && [ $language != C ]; then
				if [ -e "$path/$name/author" ]; then
					echo "Author file already exist."
				elif [ ! $USER ]; then
					echo "ENV variable USER not found, empty author file created."
					touch $path/$name/author
				else
					echo $USER > $path/$name/author
				fi
			fi
		;;
		"-git")
			echo "-git must be first option, project files created without cloning from git respository."
		;;
	esac
	shift
done
