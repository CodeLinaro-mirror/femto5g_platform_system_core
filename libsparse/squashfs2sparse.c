/*
 * Copyright (c) 2021 Qualcomm Innovation Center, Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted (subject to the limitations in the
 * disclaimer below) provided that the following conditions are met:
 *
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *    * Redistributions in binary form must reproduce the above
 *      copyright notice, this list of conditions and the following
 *      disclaimer in the documentation and/or other materials provided
 *      with the distribution.
 * 
 *    * Neither the name of Qualcomm Innovation Center, Inc. nor the names of its
 *      contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 * 
 * NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE
 * GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
 * HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <error.h>
#include <errno.h>
#include <stdint.h>

#define TEMP_FAILURE_RETRY(exp) ({         \
    typeof (exp) _rc;                      \
    do {                                   \
        _rc = (exp);                       \
    } while (_rc == -1 && errno == EINTR); \
    _rc; })

#define BUFSIZ 4096

struct sparse_header {

  int magic;  // 0xed26ff3a
  short int major_ver; // 0x10
  short int minor_ver; // 0x00
  short int header_size; // 0x1c
  short int chunk_header_size; // 0x0c
  int block_size; // 0x1000 or 4096
  int total_blocks_input; // image_size_in_kb/4096
  int major_ver_pad; // 0x10
  int minor_ver_pad; // 0x00
  int chunk_type; // 0xCAC1
  int total_blocks_ouput; // image_size_in_kb/4096
  int image_size; // 0x03AD400c or 61685772
};

static void helper()
{
   printf("squashfs_sparse  -  is used to prepare image which supports block update tested only for squashfs image .\n");
   printf("  squashfs_sparse is tested only for squashfs image, please check before using for any other fs type image \n");
   printf("  correct usage squashfs_sparse system.squash system.img \n");
   printf("\n");
}


int main(int argc, char *argv[])
{

   if(argc != 3) {
      helper();
      return 0;
   }

   
    int hdr_sz = 8*sizeof(int) + 4*sizeof(short int);
    printf ("header size %d \n",hdr_sz);
    struct sparse_header *spr_hd;
    spr_hd  = (struct sparse_header *)malloc(hdr_sz);
    printf ("short int %d\n",sizeof(short int));
    memset(spr_hd, 0, hdr_sz);
    /* below header is added to squashfs image, image size and number of block are determined from input image file
       all other details like majic number, major/minor ver chunk type are fixed
    */
    spr_hd->magic = 0xed26ff3a;
    spr_hd->major_ver = 0x01;
    spr_hd->minor_ver = 0x00;
    spr_hd->header_size = 0x1c;
    spr_hd->chunk_header_size = 0x0c;
    spr_hd->block_size = 0x1000;
    spr_hd->chunk_type = 0xCAC1;
    size_t so_far = 0;
    char* data, *d;
    data = (char *) malloc(BUFSIZ);
    d = data;
    size_t  written = 0;
    int fdr = open(argv[1], O_RDONLY);
    if (fdr < 0)
    {
       printf("failed to open status file %s, errno = %d [%s]\n", argv[1], errno, strerror(errno));
       return -1;
    }

    int fdw = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0664);
    if (fdw < 0)
    {
       printf("failed to open status file %s, errno = %d [%s]\n", argv[2], errno, strerror(errno));
       return -1;
    }

    long rcw = TEMP_FAILURE_RETRY(lseek64(fdw, so_far, SEEK_SET));
    if (rcw == -1) {
          fprintf(stderr, "lseek64 failed: %s\n", strerror(errno));
          return -1;
    }

    size_t sz = lseek(fdr, 0, SEEK_END);
    printf (" size of file %x\n",sz);
    spr_hd->total_blocks_input = sz/4096;
    spr_hd->major_ver_pad = 0x01;
    spr_hd->minor_ver_pad = 0x00;
    spr_hd->total_blocks_ouput = spr_hd->total_blocks_input;
    spr_hd->image_size = sz + 12;

    printf ("*****************************************sparse header:  %x \n", spr_hd->magic);
    printf ("*****************************************sparse header:  %x \n", spr_hd->major_ver);
    printf ("*****************************************sparse header:  %x \n", spr_hd->minor_ver);
    printf ("*****************************************sparse header:  %x \n", spr_hd->header_size);
    printf ("*****************************************sparse header:  %x \n", spr_hd->chunk_header_size);
    printf ("*****************************************sparse header:  %x \n", spr_hd->block_size);
    printf ("*****************************************sparse header:  %x \n", spr_hd->total_blocks_input);
    printf ("*****************************************sparse header:  %x \n", spr_hd->chunk_type);
    printf ("*****************************************sparse header:  %x \n", spr_hd->total_blocks_ouput);
    printf ("*****************************************sparse header:  %x \n", spr_hd->image_size);
    ssize_t w = TEMP_FAILURE_RETRY(write(fdw, (char *)spr_hd, hdr_sz));
    if (w == -1) {
       fprintf(stderr, "write failed: %s\n", strerror(errno));
       return -1;
    }



    long rcr = TEMP_FAILURE_RETRY(lseek64(fdr, so_far, SEEK_SET));
    if (rcr == -1) {
        fprintf(stderr, "lseek64 failed: %s\n", strerror(errno));
        return -1;
    }

    int count=0;
    w=0;
    while (written < sz) {
       printf (" read so_far %x \n", so_far);
       printf (" buffer size reached, reset \n");
       long rcr = TEMP_FAILURE_RETRY(lseek64(fdr, BUFSIZ*count, SEEK_SET));
       if (rcr == -1) {
           fprintf(stderr, "lseek64 failed: %s\n", strerror(errno));
           return -1;
       }

       rcw = TEMP_FAILURE_RETRY(lseek64(fdw, BUFSIZ*count + hdr_sz, SEEK_SET));
       if (rcw == -1) {
           fprintf(stderr, "lseek64 failed: %s\n", strerror(errno));
           return -1;
       }

       d = data;
       so_far = 0;
       int r = TEMP_FAILURE_RETRY(read(fdr, d, BUFSIZ));
       if (r == -1) {
          fprintf(stderr, "read failed: %s\n", strerror(errno));
          return -1;
       }
       printf (" read bytes %d \n", r);

       ssize_t w = TEMP_FAILURE_RETRY(write(fdw, d, BUFSIZ));
       if (w == -1) {
          fprintf(stderr, "write failed: %s\n", strerror(errno));
          return -1;
       }
       printf (" written bytes %d \n", w);
       printf ("data read and write %d \n", r);
       so_far += r;
       written += w;
       count=count+1;
       printf ("############################################### iteration \n\n\n");
    }
    if (close(fdw) == -1) {
       printf("close  failed: %s\n", strerror(errno));
       return -1;
    }
    if (close(fdr) == -1) {
       printf("close  failed: %s\n", strerror(errno));
       return -1;
    }

    return 0;
}
