/*
Copyright 2018 Shakher Sharma ( Shakher.Sharma@Outlook.COM )

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to 
do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
THE SOFTWARE.

  Name        	: Shakher Sharma ( Shakher.Sharma@Outlook.COM )
  Version     	: 1.0
  Creation Date	: 01-Jul-2018
  Description 	: This SQL returns details of agent's job. Used as SQL for 
                  Agent Job Report DM. 
*/
select
  job_id,
  path,
  job_name,
  job_desc,
  priority,
  created_by,
  last_runtime_ts,
  next_runtime_ts,
  disabled,
  no_end_date,
  start_date_time,
  end_date_time,
  timezone,
  frequency,
  deleted
from
  (
    select
      job.job_id                                    job_id,
      substr( path.job_param,
              1,
              instr( path.job_param, '/',-1 ) )     path,
      job.name                                      job_name,
      job.desc_text                                 job_desc,
      priority.job_param                            priority,
      job.user_id                                   created_by,
      job.last_runtime_ts                           last_runtime_ts,
      job.next_runtime_ts                           next_runtime_ts,
      decode( 
        job.disable_flg, 
          0, 'No', 
          1, 'Yes')                                 disabled,
      decode( 
        job.has_end_dt_flg,
          0, 'No',
          1, 'Yes')                                 no_end_date,
      case job.trigger_type
        when 5 then null
        else
          to_date(
            job.begin_year
            ||  '-'
            ||  lpad(begin_month, 2, '0')
            ||  '-'
            ||  lpad(begin_day, 2, '0') 
            ||  '-'
            ||  lpad(start_hour, 2, '0') 
            ||  '-'
            ||  lpad(start_minute, 2, '0'), 
            'YYYY-MM-DD HH24:MI')
      end                                           start_date_time,
      case job.trigger_type
        when 5 then null
        else
          decode( 
            job.has_end_dt_flg,
              1,  to_date(
                    job.end_year
                    ||  '-'
                    ||  lpad(end_month, 2, '0')
                    ||  '-'
                    ||  lpad(end_day, 2, '0') 
                    ||  '-'
                    ||  lpad(end_hour, 2, '0') 
                    ||  '-'
                    ||  lpad(end_minute, 2, '0'), 
                    'YYYY-MM-DD HH24:MI'),
              null)
      end                                           end_date_time,
      job.tz_name                                   timezone,
      decode( 
        job.trigger_type,
          0, 'Once',
          1, 'Daily',
          2, 'Weekly',
          4, 'Monthly',
          5, 'Never')                               frequency,
      decode( job.delete_flg,
                '1', 'Yes',
                0, 'No')                            deleted
    from
      biee_biplatform.s_nq_job        job,
      biee_biplatform.s_nq_job_param  path,
      biee_biplatform.s_nq_job_param  priority
    where 
      job.script_type = 'iBot' and
      path.job_id (+) = job.job_id and
      path.delete_flg (+) = job.delete_flg and
      path.relative_order = 1 and
      priority.job_id (+) = job.job_id and
      priority.delete_flg (+) = job.delete_flg and
      priority.relative_order = 2 
  )
where
  ( 'All' in ( :p_disabled || 'All' ) or disabled in ( :p_disabled ) )              and
  ( 'All' in ( :p_created_by || 'All' ) or created_by in ( :p_created_by ) )        and
  ( 'All' in ( :p_job_name || 'All' ) or job_name in ( :p_job_name ) )              and      
  ( 'All' in ( :p_has_end_date || 'All' ) or no_end_date in ( :p_has_end_date ) )   and
  ( 'All' in ( :p_deleted_flag || 'All') or deleted in ( :p_deleted_flag ) )        and
  ( 'All' in ( :p_frequency || 'All') or frequency  in ( :p_frequency ) )           and
  ( 'All' in ( :p_priority || 'All') or priority in ( :p_priority ) )               and
  ( 'All' in ( :p_path || 'All') or path in ( :p_path ) )                           and
  ( :p_last_runtime_ts_start is null 
      or trunc( nvl( last_runtime_ts, sysdate ) ) >= :p_last_runtime_ts_start )     and
  ( :p_last_runtime_ts_end is null 
      or trunc( nvl( last_runtime_ts, sysdate ) ) <= :p_last_runtime_ts_end )       and
  ( :p_next_runtime_ts_start is null 
      or trunc( nvl( next_runtime_ts, sysdate ) ) >= :p_next_runtime_ts_start )     and
  ( :p_next_runtime_ts_end is null 
      or trunc( nvl( next_runtime_ts, sysdate ) ) <= :p_next_runtime_ts_end )       and
  ( :p_start_date_time_start is null 
      or trunc( nvl( start_date_time, sysdate ) ) >= :p_start_date_time_start )     and
  ( :p_start_date_time_end is null 
      or trunc( nvl( start_date_time, sysdate ) ) <= :p_start_date_time_end )       and
  ( :p_end_date_time_start is null 
      or trunc( nvl( end_date_time, sysdate ) ) >= :p_end_date_time_start )         and
  ( :p_end_date_time_end is null 
      or trunc( nvl( end_date_time, sysdate ) ) <= :p_end_date_time_end )           
order by
  path,
  job_name
