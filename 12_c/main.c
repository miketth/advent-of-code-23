#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

const char* filename = "inputs/example";

void read_file(char*** lines, int* num_lines) {
    *num_lines = 0;

    FILE* file = fopen(filename, "r");
    if (file == NULL) {
        printf("Error opening file\n");
        exit(1);
    }

    char* line = NULL;
    size_t len = 0;
    ssize_t read;
    while ((read = getline(&line, &len, file)) != EOF) {
        if (line[0] == '\0') {
            continue;
        }

        char* line_copy = malloc((read + 1) * sizeof(char));
        strcpy(line_copy, line);

        (*num_lines)++;
        *lines = realloc(*lines, *num_lines * sizeof(char*));
        (*lines)[*(num_lines) - 1] = line_copy;
    }
    free(line);

    fclose(file);
}

typedef struct {
    char* springs;
    int* num_list;
} Line;

typedef struct {
    char** strings;
    int size;
} DynamicStringArray;

void add_string(DynamicStringArray* array, char* string) {
    array->size++;
    array->strings = realloc(array->strings, array->size * sizeof(char*));
    array->strings[array->size - 1] = string;
}

void add_string_copied(DynamicStringArray* array, char* string) {
    char* string_copy = malloc((strlen(string) + 1) * sizeof(char));
    strcpy(string_copy, string);
    add_string(array, string_copy);
}

void free_string_array(DynamicStringArray* array) {
    for (int i = 0; i < array->size; i++) {
        free(array->strings[i]);
    }
    free(array->strings);
}

Line parse_line(char* line) {
    int springs_len = 0;
    while (line[springs_len] != ' ') {
        springs_len++;
    }

    char* springs = malloc((springs_len + 1) * sizeof(char));
    strncpy(springs, line, springs_len);
    springs[springs_len] = '\0';

    int num_list_len = 0;
    char* num_start = line + springs_len + 1;
    int i = 0;
    while (num_start[i] != '\0') {
        if (num_start[i] == ',') {
            num_list_len++;
        }
        i++;
    }
    num_list_len++;

    int* num_list = malloc((num_list_len + 1) * sizeof(int));
    num_list[num_list_len] = -1;

    char* token = strtok(num_start, ",");
    i = 0;
    while (token != NULL) {
        num_list[i++] = atoi(token);
        token = strtok(NULL, ",");
    }

    Line parsed_line = {springs, num_list};
    return parsed_line;
}

int* group_counts(char* springs) {
    int* counts = malloc(0);
    int num_counts = 0;

    int curr_len = 0;
    for (int i = 0; i < strlen(springs); i++) {
        if (springs[i] == '#') {
            curr_len++;
        } else {
            if (curr_len > 0) {
                num_counts++;
                counts = realloc(counts, num_counts * sizeof(int));
                counts[num_counts - 1] = curr_len;
                curr_len = 0;
            }
        }
    }
    if (curr_len > 0) {
        num_counts++;
        counts = realloc(counts, num_counts * sizeof(int));
        counts[num_counts - 1] = curr_len;
    }


    counts = realloc(counts, (num_counts + 1) * sizeof(int));
    counts[num_counts] = -1;

    return counts;
}

int count_char(char* str, char c) {
    int count = 0;
    for (int i = 0; i < strlen(str); i++) {
        if (str[i] == c) {
            count++;
        }
    }
    return count;
}

int sum_list(int* list) {
    int sum = 0;
    for (int i = 0; list[i] != -1; i++) {
        sum += list[i];
    }
    return sum;
}


void swap(char *x, char *y) {
    char temp = *x;
    *x = *y;
    *y = temp;
}

bool shouldSwap(char *str, int start, int curr) {
    for (int i = start; i < curr; i++) {
        if (str[i] == str[curr]) {
            return false;
        }
    }
    return true;
}

void permute(char* str, int l, int r, DynamicStringArray* out) {
    if (l == r) {
        add_string_copied(out, str);
    } else {
        for (int i = l; i <= r; i++) {
            // Proceed further for str[i] only if it doesn't match with any of the characters after str[start]
            if (shouldSwap(str, l, i)) {
                swap((str + l), (str + i));
                permute(str, l + 1, r, out);
                swap((str + l), (str + i)); // Backtrack
            }
        }
    }
}

char* gen_str(int num_hash, int num_dot) {
    char* str = malloc((num_hash + num_dot + 1) * sizeof(char));
    for (int i = 0; i < num_hash; i++) {
        str[i] = '#';
    }
    for (int i = 0; i < num_dot; i++) {
        str[num_hash + i] = '.';
    }
    str[num_hash + num_dot] = '\0';
    return str;
}

bool num_list_eq(int* list1, int* list2) {
    for (int i = 0; list1[i] != -1; i++) {
        if (list1[i] != list2[i]) {
            return false;
        }
    }
    return true;
}

char* substitute_q(char* springs, char* permutation) {
    char* new_springs = malloc((strlen(springs) + 1) * sizeof(char));
    int subs_idx = 0;
    for (int spring_idx = 0; spring_idx < strlen(springs); spring_idx++) {
        if (springs[spring_idx] == '?') {
            new_springs[spring_idx] = permutation[subs_idx++];
        } else {
            new_springs[spring_idx] = springs[spring_idx];
        }
    }
    new_springs[strlen(springs)] = '\0';
    return new_springs;
}

int count_valid_permutations(Line line) {
    int num_q = count_char(line.springs, '?');
    int num_hash = count_char(line.springs, '#');
    int sum = sum_list(line.num_list);
    int remaining_hash = sum - num_hash;
    int remaining_dot = num_q - remaining_hash;
    char* str = gen_str(remaining_hash, remaining_dot);

    DynamicStringArray permutations = {malloc(0), 0};
    permute(str, 0, strlen(str) - 1, &permutations);

    int count = 0;
    for (int i = 0; i < permutations.size; i++) {
        char* new_springs = substitute_q(line.springs, permutations.strings[i]);
        int* counts = group_counts(new_springs);
        free(new_springs);
        if (num_list_eq(counts, line.num_list)) {
            count++;
        }
        free(counts);
    }

    free(str);
    free_string_array(&permutations);
    return count;
}

int main() {
    char** lines = malloc(0);
    int num_lines = 0;
    read_file(&lines, &num_lines);

    Line* parsed_lines = malloc(num_lines * sizeof(Line));
    for (int i = 0; i < num_lines; i++) {
        parsed_lines[i] = parse_line(lines[i]);
        free(lines[i]);
    }
    free(lines);

    int sum = 0;

    for (int i = 0; i < num_lines; i++) {
        int count = count_valid_permutations(parsed_lines[i]);
        sum += count;
    }

    printf("First part: %d\n", sum);

    for (int i = 0; i < num_lines; i++) {
        free(parsed_lines[i].springs);
        free(parsed_lines[i].num_list);
    }

    free(parsed_lines);

    return 0;
}
