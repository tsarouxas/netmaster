<?php

###############################################################
# cPanel WHM Account Creator 1.1
###############################################################
###############################################################
# Required parameters:
# - domain - new account domain
# - user - new account username
# - password - new account password
# - package - new account hosting package (plan)
# - email - contact email
#
# Sample run: create-whm-account.php?domain=reseller.com&user=hosting&password=manager&package=unix_500
#
# If no parameters passed then input form will be shown to enter data.
#
# This script can also be run from another PHP script. This may
# be helpful if you have some user interface already in place and 
# want to automatically create WHM accounts from there.
# In this case you have to setup following variables instead of
# passing them as parameters:
# - $user_domain - new account domain
# - $user_name - new account username
# - $user_pass - new account password
# - $user_plan - new account hosting package (plan)
# - $user_email - contact email
#
###############################################################

///////  YOUR WHM LOGIN DATA
$whm_user   = '';      // reseller username
$whm_pass   = '';  // the password you use to login to WHM

#####################################################################################
##############          END OF SETTINGS. DO NOT EDIT BELOW    #######################
#####################################################################################

$whm_host   = ''; //the domain name of your server

function getVar($name, $def = '') {
  if (isset($_REQUEST[$name]))
    return $_REQUEST[$name];
  else
    return $def;
}

// Domain name of new hosting account
// To create subdomain just pass full subdomain name
// Example: newuser.hellenictechnologies.com
if (!isset($user_domain)) {
  $user_domain = getVar('domain');
}

// Username of the new hosting account
if (!isset($user_name)) {
  $user_name = getVar('user');
}

// Password for the new hosting account
if (!isset($user_pass)) {
  $user_pass = getVar('password');
}

// New hosting account Package
if (!isset($user_plan)) {
  $user_plan = getVar('package');
}

// Contact email
if (!isset($user_email)) {
  $user_email = getVar('email');
}

// if parameters passed then create account
if (!empty($user_name)) {

  // create account on the cPanel server
  $script = "https://{$whm_user}:{$whm_pass}@{$whm_host}:2087/scripts/wwwacct";
  $params = "?plan={$user_plan}&domain={$user_domain}&username={$user_name}&password={$user_pass}&contactemail={$user_email}";
  $result = file_get_contents($script.$params);

  // output result
  echo "RESULT: " . $result;
}
// otherwise show input form
else {
$frm = <<<EOD
<html>
<head>
  <title>cPanel/WHM Account Creator</title>
  <META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
  <META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
</head>
<body>
  <style>
    input { border: 1px solid black; }
  </style>
<form method="post">
<h3>cPanel/WHM Account Creator</h3>
<table border="0">
<tr><td>Domain:</td><td><input name="domain" size="30"></td><td>Subdomain or domain, without www</td></tr>
<tr><td>Username:</td><td><input name="user" size="30"></td><td>Username to be created</td></tr>
<tr><td>Password:</td><td><input name="password" size="30"></td><td></td></tr>
<tr><td>Package:</td><td><input name="package" size="30"></td><td>Package (hosting plan) name. Make sure you cpecify existing package</td></tr>
<tr><td>Contact Email:</td><td><input name="email" size="30"></td><td></td></tr>
<tr><td colspan="3"><br /><input type="submit" value="Create Account"></td></tr>
</table>
</form>
</body>
</html>
EOD;
echo $frm;
}

?>