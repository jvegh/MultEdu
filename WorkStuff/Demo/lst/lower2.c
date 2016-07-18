/* Convert string to lowercase: faster */
void lower2(char *s)
{
	int i;
	int len = strlen(s);
	for (i = 0; i < len; i++)
	
		if (s[i] >= 'A' && s[i] <= 'Z')
			s[i] -= ('A' - 'a');
}
