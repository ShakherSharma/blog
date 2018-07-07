-- Priorities
select 
  distinct job_param
from
  biee_biplatform.s_nq_job_param
where
  relative_order = 2 and
  job_id in ( select 
                job_id 
                    from 
                biee_biplatform.s_nq_job
                    where
                script_type = 'iBot' )
        
                
-- Jobs
select 
  name 
from 
  biee_biplatform.s_nq_job 
order by 1


-- Paths
select 
  distinct substr( job_param,
                      1,
                       instr( job_param, '/',-1 ) ) 
from 
  biee_biplatform.s_nq_job_param 
where 
  relative_order = 1 and
  job_id in ( select job_id 
              from   biee_biplatform.s_nq_job
              where script_type = 'iBot')

              
-- Users
select 
  distinct user_id 
from 
  biee_biplatform.s_nq_job

