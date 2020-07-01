/* gcc `pkg-config libevent glib-2.0 --libs --cflags` Hostname.c */
/*
域名是一个ascii的字符串，后面支持非ascii的域名。
非ascii的域名可以转换成ascii的域名访问。
gchar *	g_hostname_to_ascii ()
gchar *	g_hostname_to_unicode ()
gboolean	g_hostname_is_non_ascii (const gchar *hostname)
gboolean	g_hostname_is_ascii_encoded (const gchar *hostname)
gboolean	g_hostname_is_ip_address (const gchar *hostname)
*/

#include <stdio.h>

#include <glib.h>
#include <glib/gi18n.h>
int main(int argc, char **argv)
{
    
    gchar *myhostname_ascii = g_hostname_to_ascii ("中文.com.cn");
    
    if (myhostname_ascii) {
        /* 中文.com.cn转换后的域名是xn--fiq228c.com.cn */
        printf("中文.com.cn转换后的域名是%s\n", myhostname_ascii);
        gchar *myhostname_unicode = g_hostname_to_unicode (myhostname_ascii);
        if (myhostname_unicode) {
            /* xn--fiq228c.com.cn转换前的域名是中文.com.cn */
            printf("xn--fiq228c.com.cn转换前的域名是%s\n", myhostname_unicode);
            g_free(myhostname_unicode);
        }
        g_free(myhostname_ascii);
    }
    
    return 0;
}

