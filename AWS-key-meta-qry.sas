/* SAS code by David Glemaker for pulling key and secret key out of instance metadata */
/* Origainally done for POC @ Amgen */

filename s3acc pipe "curl http://169.254.169.254/latest/meta-data/iam/security-credentials/sna-hls";
filename awscred "/home/$USER/.aws/credentials" ;*permission="600";
filename awsconf "/home/$USER/.aws/config" ;
data _null_;
   file awsconf;
   put "[default]";
   put "output = json";
   put "region = us-east-1";
run;
data _null_;
   file awscred;
   infile s3acc firstobs=2 dlm=":," missover;
   length type $30. value $1500.;
   input type $ value $;
   value=compress(compress(value),'"');
     if _n_=1 then put "[default]";
      if type='"AccessKeyId"' then put "aws_access_key_id = " value;
      if type='"SecretAccessKey"' then put "aws_secret_access_key = " value;   
     if type='"Token"' then put "aws_session_token = " value; 
run;
