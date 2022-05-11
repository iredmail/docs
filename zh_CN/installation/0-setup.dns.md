# 为你的 iRedmail 服务器配置 DNS 记录 (A, PTR, MX, SPF, DKIM, DMARC)

[TOC]

__重要提醒__: `A`，`MX` 记录是必须要有的，除此之外 `Reverse PTR`，`SPF`，
`DKIM` 和 `DMARC` 记录是可选的，但是我们 __强烈__ 建议使用。

## `A` 记录（服务器主机名） {: id="a" }

### ”`A` 记录“是什么

一个 `A` 记录将一个 FQDN (fully qualified domain name ，翻译为完全限定域名）映射到一个 IP(v4) 地址。这种记录
也可能是在整个 DNS 系统中最常使用的一种 DNS 记录。如果说
你想要把一个域名指向一个网站服务器，你就应该使用此类 DNS 记录。

### 如何建立一个 `A` 记录

* `Name`: 这将是在你的域名的一个主机，实际上就是在你的
  域名内的一个电脑。你的域名将会被自动添加到你在此输入的值（ `Name` ）后面。
  比如说你想创建一个域名为 `www.mydomain.com` 的 `A` 记录，你在此则需要
  输入的数值将是 `www` 。

    __注意__: 如果说你将此数值不填，你想要创建的记录将会
    自动使用你的基础域名（ base domain ）`mydomain.com` 。 包含你的基础域名的记录
    叫做根记录（ root record ）或者最高记录（ apex record ）。

* `IP`: 完全限定域名的目标 IP 地址。你可以把一个 IP 地址理解为
  用来联系你的电脑的一个电话号码。有了它其他的电脑才知道
  如何去联系到你的电脑。其格式也和电话号码相似，也包含着像电话号码一样的国家，区域编号
  和电话号码。

* `TTL`: TTL (Time to Live) ，翻译为存活时间，是一个用来决定一条 DNS 记录
  能最多在一个先前发出请求的系统的缓存里存活的时间的数值。此系统可以是一个发出请求的
  名称服务器或者一个用户浏览器。此数值以秒数（ second ）为准，所以说 60 为一分钟，1800 是 30 分钟，等等。

  设有一个静态 IP 地址的系统携带的 TTL 应不小于 1800 。
  设有一个动态 IP 地址的系统携带的 TTL 应不大于 1800 。

  一个有更小 TTL 的 DNS 记录意味着任何一个客户端
  将会更频繁的向目标名称服务器发送询问请求，
  从而导致你的域名的 DNS 流量的增长。当你的 IP 地址变动频率很大，
  但是 TTL 数值又很高时，目标主机运行的服务可能会受到影响。

案例记录：

```
NAME                TTL     TYPE    DATA

www.mydomain.com.   1800    A       192.168.1.2
mail.mydomain.com.  1800    A       192.168.1.5
```

以上两条记录作用是将 `www.mydomain.com` 指向 IP 地址 `192.168.1.2` ，
以及将 `mail.mydomain.com` 指向 `192.168.1.5` 。

## 服务器 IP 地址的反向 PTR 记录 {: id="ptr" }

### 反向 PTR 记录是什么

一个 PTR 记录，或更合适的说一个反向 PTR 记录（ Reverse PTR Record ）
能够让一个系统查询到一个 IP 地址对应的域名。这个查询过程正好与查询
一个域名对应的 IP 地址（ `A` 记录）的过程完全相反。比如说当你 
ping 一个域名 `mail.mydomain.com` 时，此域名将会被自动被翻译
成对应的 IP 地址 `192.168.1.5` 。一个反向 PTR 记录的工作原理正好完全相反；
它使用一个 IP 地址作为输入，然后输出其对应的域名。
在以上案例中，IP 地址 `192.168.1.5` 将会被翻译成 `mail.mydomain.com` 。

### 为什么我们会需要一个反向 PTR 记录

反向 PTR 记录最常见的用途是垃圾邮件筛选。其工作原理是，
一般发送垃圾邮件的邮件服务器都会使用假域名，同时一般不会
正确的在 ISP 的 DNS 区域里配置好反向 PTR 记录。垃圾邮件过滤器
一般会使用这个评判标准来发现垃圾邮件服务器。如果说你的
邮件服务器没有正确的配置好一个反向 PTR 记录，从你的邮件服务器发出
的邮件就 __有可能__ 会被垃圾邮件过滤软件屏蔽。

### 如何建立一个反向 PTR 记录

你可能需要联系你的网络提供商（ ISP 或 Internet Service Pxrovider ）
然后申请为你的邮件服务器的 IP 地址创建一个反向 PTR 记录。比如说你的
邮件服务器域名是 `mail.mydomain.com` ，你就可以请求你的 ISP 为你
在其反向 DNS 域里创建一个反向 PTR 记录 `192.168.1.5` 
（你的邮件服务器的公网 IP 地址）。尽管你一般自己管理自己的正向 DNS 域，
反向 DNS 域是由你的 ISP 管理的。

## 你的邮件域名的 MX 记录 {: id="mx" }

### MX 记录是什么

邮件交换记录（ Mail Exchange Record ），简称 MX 记录，
是用来让其他邮件服务器知道你的域名的邮件服务器的位置。当
一个人给任何一个在你的邮件服务器上的用户发邮件时，
其 MX 记录提供发送此邮件的目标 IP 地址（邮件服务器的 IP 地址）。
MX 记录是你用 DNS 系统向整个世界
发布的你的域名的邮件服务器地址。

很多 DNS 名称都有多个 MX 记录，意味着你可以为
一个 DNS 名称创立多个邮件服务器来接受邮件。
每个 MX 记录有一个优先权数值（ priority number ）。
__有最低的优先权数值的 MX 记录的优先权最高__，
也一般是你的主邮件服务器。下一个更低的优先权数值意味着一个副邮件服务器，
然后等等。你一般会有多个邮件服务器，其中包含一个主要邮件服务器，
和多个其他的备用服务器。同时只使用一个邮件服务器的 MX 记录也是可以的。

### 如何建立 MX 记录

如果你的 ISP 或域名注册商提供 DNS 服务的话，
你可以要求他们为你建立一个 MX 记录。 如果说你自己管理自己的 DNS 服务的话，
那你就需要自己在你的 DNS 域的创建 MX 记录。

实例 MX 记录：

```
NAME            PRIORITY    TYPE    DATA

mydomain.com.   10          mx      mail.mydomain.com.
```

此记录所产生的效应是：向 `[user]@mydomain.com` 发送的邮件
会被转递到邮件服务器 `mail.mydomain.com` 。

## 域名自动识别

### 自动配置/自动发现记录（ autoconfig/autodiscover record ）是什么

`autoconfig/autodiscover.company.com` 让邮件客户端自动获取一个在此域名下的用户邮箱的配置
信息。 如果有一个需要配置的邮箱属于 `user@company.com` ，则邮件客户端将会检查 
`autodiscover.company.com` 来获取正确的配置。

更多关于自动配置/识别的信息请参考此页面（英文）：
[Setup DNS records for autoconfig and autodiscover](https://docs.iredmail.org/iredmail-easy.autoconfig.autodiscover.html).

### 如何建立自动配置/自动发现记录

如果你的 ISP 或域名注册商提供 DNS 服务的话，
你可以要求他们为你建立一个自动配置/自动发现记录。 如果说你自己管理自己的 DNS 服务的话，
那你就需要自己在你的 DNS 域的创建自动识别/自动发现记录。

范例自动配置/自动发现记录：

```
NAME            PRIORITY    TYPE    DATA

autodiscover.mydomain.com.   10          mx      mail.mydomain.com.
autoconfig.mydomain.com.   10          mx      mail.mydomain.com.
```

## 邮件域名的 SPF 记录 {: id="spf" }

### SPF 记录是什么

SPF 是一个垃圾邮件（ spam ）和钓鱼诈骗（ phishing ）的对策方法。SPF DNS 记录会被用来定义
允许使用此域名来发出邮件的主机。关于 SPF 的详情，请前往其[维基百科页面](https://en.wikipedia.org/wiki/Sender_Policy_Framework)
（英文）。

此方法的工作原理是使用一个 SPF DNS 记录，然后在其中定义允许从预定域名发出邮件的主机的（电子邮件
服务器） IP 地址。

在其他邮件服务器接收到一个从某预定域名发出的邮件时，
此邮件服务器根据域名的 SPF 记录检查发出此邮件的主机
的 IP 地址是否有权限使用此域名发出邮件。

### 如何建立一个 SPF 记录

SPF 记录以 TXT DNS 记录的形式存在。你可以将发送主机的 IP 地址或 MX DNS 名称在此记录中列出。
请参见一下范例：

```
mydomain.com.   3600    IN  TXT "v=spf1 mx -all"
```

这条 SPF 记录表达的意义是：所有在域名 `mydomain.com` 的 MX 记录里定义的邮件服务器主机有权限
以任意一个在此域名下的地址（比如 `someone@mydomain.com` ）发出电子邮件。

以上的案例记录中的 `-all` 表示所有除域名 MX 记录中定义的 IP 地址之外的所有主机都没有以此域名发
出邮件的权限。 如果你觉得这种定义方式太过严格，你可以选择使用 `~all` ，来表示软失败（不确定）。

你也可以直接使用 IP 地址来定义允许的发送主机：

```
mydomain.com.   3600    IN  TXT "v=spf1 ip4:111.111.111.111 ip4:111.111.111.222 -all"
```

当然你可以在一个记录中同时使用以上的两种或更多定义方式：

```
mydomain.com.   3600    IN  TXT "v=spf1 mx ip4:111.111.111.222 -all"
```

关于更多的有效定义机制，请参看此
[维基百科页面](https://en.wikipedia.org/wiki/Sender_Policy_Framework)。

## 邮件域名的 DKIM 记录 {: id="dkim" }

### DKIM 记录是什么

DKIM 记录能让一个邮件收件人验证是否他/她收到的邮件是真的从属实的
机构邮件服务器发出的。一个机构可以作为一个发件人的，发信域名的，
或一个中介的邮件的直接的管理者。当然它也可以
是一个非直接的管理者，比如一个为一个直接管理者服务的独立服务。
DKMI 使用公钥密码学（ Public Key Cryptography ）和基于 DNS 系统的密钥服务器，
定义一个域名级别的数字签名验证框架
（ [RFC4871](http://www.dkim.org/specs/rfc5585.html#RFC4871) （英文））。
次验证机制能够使收信服务器验证各邮件的签字人（发信人），以及邮件内容的完整性。
DKMI 允许签字人发布关于他/她的签字习惯（ Signing Practices ）；
这样就可以让收件人们对未签名的邮件进行更一步的检阅。
DKMI 的邮件身份验证机制可以帮助在全球范围的垃圾，钓鱼邮件的控制。





一个个人或组织都有一个 “身份”，也就是一系列把他们于其他身份区分开的特征。
用这种方式思考的话，我们就可以使用一个标记作为参考，
或“标识符“。这就是一个物体和其标识符的区别。
DKMI 使用一个域名作为标识符来指代一个负责组织或个人。
在 DKIM 中这个标识符也称签字域名标识符（ Signing Domain Identifier ），
包含在 DKMI 签名头字段中的 `d=` 标签中。值得注意的是，同一个身份可以有多个标识符。



### 如何建立 DKIM 标识符

* 在终端中输入以下命令来查询你的 DKMI 密钥：

    !!! attention

      * 在某些 Linux/BSD 发行版中，你应该使用 `amavisd-new` 命令，而不是 `amavisd` 。
      * 在 CentOS 中，如果说命令出错并输出 `/etc/amavisd.conf not found`，请在执行的命令中包括其配置文件的路径，例如：

        ```amavisd -c /etc/amavisd/amavisd.conf showkeys```



```bash
# amavisd showkeys
dkim._domainkey.mydomain.com.   3600 TXT (
  "v=DKIM1; p="
  "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYArsr2BKbdhv9efugByf7LhaK"
  "txFUt0ec5+1dWmcDv0WH0qZLFK711sibNN5LutvnaiuH+w3Kr8Ylbw8gq2j0UBok"
  "FcMycUvOBd7nsYn/TUrOua3Nns+qKSJBy88IWSh2zHaGbjRYujyWSTjlPELJ0H+5"
  "EV711qseo/omquskkwIDAQAB")
```

* 将以上命令输出转化到一行里，如下所示。 你需要移除所有的引号，并保留所有的 `;` 。__我们只需要括号内的部分__，也就是 DKMI DNS 记录的内容。



```
v=DKIM1; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYArsr2BKbdhv9efugBy...
```

__注意__: BIND （[最广泛使用的域名服务器软件](http://www.isc.org/downloads/bind/))
可以处理此类多行格式，所以说在此情况下你可以将其直接粘贴到你的域名区文件中。


* 为域名 `dkim._domainkey.mydomain.com` 添加 `TXT` DNS 记录，并将内容设为上一步复制的数值： `v=DKIM1; p=...`.


  > 注意：一个常犯的错误是将此 DMIM 记录添加到主域名 `mydomain.com` ，这种做法是错误的。请保证新创建的记录名是 `dkim._domainkey.mydomain.com` 。



* 添加此记录以后，使用 `dig` 或 `nslookup` 来做验证：

```
$ dig -t txt dkim._domainkey.mydomain.com

$ nslookup -type=txt dkim._domainkey.foodmall.com
```

范例输出：

```
dkim._domainkey.mydomain.com. 600 IN TXT	"v=DKIM1\;p=..."

```

使用 Amavisd 验证：

```shell
# amavisd testkeys
TESTING: dkim._domainkey.mydomain.com       => pass
```

若输出为 `pass` ，则说明验证通过。

__注意__: 如果说你的 DNS 服务是由 ISP 提供的，新创建的 DNS 记录可能会在数小时后生效。


如果说你想要为当前域名重新生成 DKIM 密钥，或要为新的域名生成 DKIM 密钥，请参照此教程（英文）：
[Sign DKIM signature on outgoing emails for new mail domain](./sign.dkim.signature.for.new.domain.html) 。


## 邮件域名的 DMARC 记录 {: id="dmarc" }

### 什么是 DMARC 记录？并且其对抗钓鱼诈骗的方式

以下引用 [ dmarc.org 网站的常见问题页面 ](https://dmarc.org/wiki/FAQ) （强烈建议阅读整个常见问题网页）：


> DMARC is a way to make it easier for email senders and receivers to determine
> whether or not a given message is legitimately from the sender, and what to
> do if it isn’t. This makes it easier to identify spam and phishing messages,
> and keep them out of peoples’ inboxes.
>
> DMARC is a proposed standard that allows email senders and receivers to
> cooperate in sharing information about the email they send to each other.
> This information helps senders improve the mail authentication infrastructure
> so that all their mail can be authenticated. It also gives the legitimate
> owner of an Internet domain a way to request that illegitimate messages –
> spoofed spam, phishing – be put directly in the spam folder or rejected
> outright.

一些在 <https://dmarc.org> 上有用的文档（英文）：

* [DMARC FAQ](https://dmarc.org/wiki/FAQ)
    * [Why is DMARC Important?](https://dmarc.org/wiki/FAQ#Why_is_DMARC_important.3F)
* [How Does DMARC Work?](https://dmarc.org/overview/)
* [Specifications](https://dmarc.org/resources/specification/)

## 如何配置 DMARC 记录

!!! attention

    DMARC 非常依赖于 SPF 以及 DKIM 记录，请保证这两种记录在你的域内以正确配置好了。




DMARC 是一个 TXT 类型的 DNS 记录：

```
v=DMARC1; p=none; rua=mailto:dmarc@mydomain.com
```

一个详细的范例记录：

```
v=DMARC1; p=reject; sp=none; adkim=s; aspf=s; rua=mailto:dmarc@mydomain.com; ruf=mailto:dmarc@mydomain.com
```

* `v=DMARC1` 表示 DMARC 协议版本。目前 `DMARC1` 是可用的，并且 `v=DMARC1` 必须是一个 
DMARC 记录的第一项。
* `adkim` 标识 DKIM 的对准模式。目前有两个可用选项：
    * `r`: 放松模式 (`akim=r`)
    * `s`: 苛刻模式 (`aspf=s`)
* `aspf` 标识 SPF 的对准模式。目前有两个可用选项：
    * `r`: 放松模式 (`aspf=r`)
    * `s`: 苛刻模式 (`aspf=s`)
* `p` 标识此组织域名的的反应政策。其内容告诉收信服务器如何在邮件未通过 DMARC 测试的情况下做出反应。目前有一下三种可用的选项：

    * `none` (`p=none`): 域名管理员表示对于信息投送不做出任何具体措施。
    * `quarantine` (`p=quarantine`): 域名管理员表示要将未通过 DMARC 测试的邮件被邮件接收方标记为可疑的。根据邮件接收方的处理能力，此应对方式可以代表 “放入垃圾邮件文件夹“，”标记为可疑的“，“隔离其邮件”，或更多其他措施。
    * `reject` (`p=reject`): 域名管理员表示要在 SMTP 传送过程中拒收未通过 DMARC 测试的邮件。

   !!! attention

      - 如果说你确定你的所有的邮件都是从 SPF 记录中的主机发出的，或者有着正确签署过的 DKIM 签名，我们则强烈建议使用 `p=reject` 。
      - 根据 [RFC 7498](https://tools.ietf.org/html/rfc7489#section-6.3) ， __“v” 和 “p” 标识必须存在并且以 “v” 在前 “p” 在后的顺序排列。__所以说一定要将 “p“ 标识立刻放在 ”v“ 标识的后面的。 例如： `v=DMARC1; p=reject; aspf=s; ...` 为正确格式。 `v=DMARC1; aspf=s; p=reject; ...` 为非正确格式。

* `sp` 定义对于所有子域名的策略。此参数是可选的。允许的数值与 `p` 相同。
* `rua` 定义传送整体回馈信息的机制。 对于此参数目前只有 `mailto:` 是被支持的。此参数是可选的。
* `ruf` 定义特定信息的错误信息使用的汇报传送机制。对于此参数目前只有 `mailto:` 是被支持的。此参数为可选的。

















## 针对 Jabber/XMPP 服务的 SRV 记录

如果说你使用 iRedMail Easy 平台安装了 Prosody ，并将其作为 Jabber/XMPP 服务器，则需要 2 个 SRV 记录。

如果说你的邮件域名是 `mydomain.com` 并且服务器主机名为 `mail.mydomain.com` ，你应该创建以下 2 个 SRV 类型的 DNS 记录：

- `_xmpp-client._tcp.mydomain.com`
- `_xmpp-server._tcp.mydomain.com`

范例记录：

```
_xmpp-client._tcp.mydomain.com 18000 IN SRV 0 5 5222 mail.mydomain.com
_xmpp-server._tcp.example.com. 18000 IN SRV 0 5 5269 mail.mydomain.com
```

其目标域名 `mail.mydomain.com` __必须__ 是一个以存在的 A 类型记录，一个 IP 地址或者 CNAME 类型的记录是不被接受的。




## 在 Google Postmaster 工具包上注册你的邮件域名

次步骤为__可选__的，但是我们__强烈建议__使用此步骤。

Google Postmaster 工具包网址 <https://postmaster.google.com> ，以及 [Postmaster Tools 常见问题页面](https://support.google.com/mail/answer/6258950)。


注册过程极其简单，你只需要在其网站上注册你的邮件域名，然后它会给你一段 TXT 记录的文字。然后在邮件域名管理页面创建次 TXT 记录。 其记录是用来验证你是否是这个域名的拥有者。


为什么要使用 Google Postmaster 工具包呢？ 参见一下 [Google Postmaster Tools 帮助页面](https://support.google.com/mail/answer/6227174)的节选：


> 如果你向 Gmail 用户发送大量的邮件的话，你可以使用 Postmaster Tools 来查看：
>
> * 是否用户将你的邮件标记为诈骗骚扰邮件。
> * 是否你在遵守 Gmail 的最佳实践。
> * 为什么你的邮件没有被正确投递。
> * 问什么你的邮件没有被安全的发送。

这样做*__也许__*可以帮助你将你的邮件移出 `Junk` 邮箱。

如果你无法将邮件传递到 Gmail 或者其他的 Google Apps ， Google 提供一些有用的资源来帮助你确保你的邮件被正确传递到 Gmail 用户：[批量发送指南](https://support.google.com/mail/answer/81126?hl=en)。



你也可以使用此线上表单来联系谷歌：[批量发件人联系表单](https://support.google.com/mail/contact/bulk_send_new?rd=1)


## 检查 Outlook.com Postmaster 网站

Outlook Postmaster 网站给邮件服务器管理员提供一些有用的信息，如果说你发送至 Outlook 的邮件被视为诈骗邮件，请参见一下资源：



- [Outlook.com Postmaster](https://sendersupport.olc.protection.outlook.com/pm/)
- [Smart Network Data Service](https://sendersupport.olc.protection.outlook.com/snds/)

## 参考链接

* [wikipedia: Sender Policy Framework](https://en.wikipedia.org/wiki/Sender_Policy_Framework)
* [http://www.dkim.org/](http://www.dkim.org/)
