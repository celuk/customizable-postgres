// You need to run this code after compile as 
// ./example_qsort datasets/big-postgres.dataset 256000

// You also need to comment the lines 313 to 317 in postgres source code src/include/lib/sort_template.h
// This lines gives error for external dataset
/*
if (DO_COMPARE(pm - ST_POINTER_STEP, pm) > 0)
{
	presorted = 0;
	break;
}
*/

// You also need to change in compile.sh the variable to EXTRACTF="tuplesort"

#include "postgres.h"

const char *progname;

#include <stdio.h>
#include <stdlib.h>

// We are using qsort_ssup from original postgres that you can also modify in place
#include "backend/utils/sort/tuplesort.c"

// This function ported from the C++ one
void __attribute__ ((noinline)) get_input_tuples_from_bin(char * FileName,
      size_t tuples_count, SortTuple * input_tuples) {
	FILE *fptr;
	fptr = fopen(FileName, "rb");
	fseek(fptr, 0, SEEK_SET);
	fread((&input_tuples[0]), sizeof(SortTuple), tuples_count, fptr);
	fclose(fptr);
}

int main(int argc, char * argv[]) {
	char * FileName = argv[1];
   // size
   size_t input_size = atoi(argv[2]);

   // Define the Sort tuple pointer
   SortTuple * input_tuple = (SortTuple*)malloc(input_size*sizeof(SortTuple));
   // Read the tuples from a binary file
   get_input_tuples_from_bin(FileName, input_size, input_tuple);

   // Define the SortSupport object
   SortSupport input_ssup = (SortSupport)malloc(sizeof(SortSupportData));

   // Add some definitions
   input_ssup->ssup_nulls_first = false;
   input_ssup->ssup_reverse = false;

   qsort_ssup(input_tuple, input_size, input_ssup);
   
   // Free the Variables
   free(input_tuple);
   free(input_ssup);
   
   printf("DONE!!!");
}
