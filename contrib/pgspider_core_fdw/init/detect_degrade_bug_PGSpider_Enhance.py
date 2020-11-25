import sys
import os
import re
import io

ResultFileName = "regression.diffs"
Previous_TC_NG_File = "Previous_TC_NG.out"
New_TC_NG_File = "New_TC_NG.out"
DegradeBug_File = "Degrade_Bug.out"

#read content of file
def readFile(fileName):
	with open(fileName, mode="r") as f:
	    return f.read().splitlines()

#create new file and write content into file
def writeFile(fileName, content):
	with open(fileName, mode="w") as f:
	    f.write(content)

#get testsFileName and Testcase ID
def getInfo(filenName,testFiles,tcid):
	Content = readFile(filenName)
	i = 0 
	while i < len(Content):
		if "BasicFeature" in Content[i]:
			testFiles.append(Content[i])
			i+=1
			tcids = []
			while "BasicFeature" not in Content[i]:
				tcids.append(Content[i])
				i+=1
				if i >=len(Content):
					break
			tcid.append(tcids)

#get index by name
def getIdx(name,list) :
        for idx, val in enumerate(list) :
                if val == name :
                        return idx

#create file contains testfilename and testcase-NG
def createFileTCNG(fileOUT):
        all_lines = readFile(ResultFileName)
        testFiles = ""
        ngContent= ""
        for i in range(len(all_lines)):
                if "+++" in all_lines[i] and "enhance_prepare.out" in all_lines[i]:
                        continue
                if "+++" in all_lines[i]:
                        testFile = all_lines[i][all_lines[i].find("BasicFeature"):all_lines[i].find(".out")+4]
                        ngContent += testFile + "\n"
                if "Testcase" in all_lines[i]:
                        tcID = all_lines[i][all_lines[i].find("Testcase")+9:all_lines[i].find(":")]
                        ngContent += tcID + "\n"
        with open(fileOUT, mode="w") as f:
            f.write(ngContent)

#detect degrade bug
if os.path.exists(Previous_TC_NG_File):
        pre_testFiles = []
        pre_tcid = []
        new_testFiles = []
        new_tcid = []

        if os.path.exists(ResultFileName) == False:
                content = "All tests passed."
                writeFile(DegradeBug_File, content)
        else:
                #create new file New_TC_NG.out from new file regression.diffs
                createFileTCNG(New_TC_NG_File)
                #read content previous file
                getInfo(Previous_TC_NG_File, pre_testFiles, pre_tcid)
                #read content new file
                getInfo(New_TC_NG_File, new_testFiles, new_tcid)

                degrade_content = ""
                for i in range(len(new_testFiles)):
                        idx = getIdx(new_testFiles[i],pre_testFiles)
                        if idx == None:
                                degrade_content+= new_testFiles[i] + " : " + ' '.join(new_tcid[i]) + "\n\n"
                                continue
                        list_tcid_new = new_tcid[i]
                        list_tcid_pre = pre_tcid[idx]
                        degrade_bug = list(set(list_tcid_new) - set(list_tcid_pre))
                        degrade_content+= new_testFiles[i] + " : " + ' '.join(degrade_bug) + "\n\n"

                writeFile(DegradeBug_File, degrade_content)

else:
        if os.path.exists(ResultFileName):
                createFileTCNG(Previous_TC_NG_File)
        else:
                os.mknod(Previous_TC_NG_File)

        #The First Test For Branch -> Degrade_Bug.out empty
        os.mknod(DegradeBug_File)

