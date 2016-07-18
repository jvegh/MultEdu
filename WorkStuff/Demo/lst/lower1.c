/* Convert string to lowercase: slow */
void lower1(char *s)
{
	 int i;

	 for (i = 0; i < strlen(s); i++)
	 if (s[i] >= 'A' && s[i] <= 'Z')
	 	s[i] -= ('A' - 'a');
}
