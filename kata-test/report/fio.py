import pandas as pd
import os
import re
import io
from IPython.display import display, Markdown
    
def check_results_dir():
    print_tests_info()
    csv_file="./results/results.csv"
    if not os.path.exists(csv_file):
        raise Exception("Not found results file:"+csv_file)

# Given df return new_df
# Where new_df is defined by 
# 'workload' | 'name[0]' | ... | 'name[n]'
# Each row has the name of the workload and the value per name
# Because names may change depending on the user
# It also returns the list of names of each run
def get_metrics_by_testname(df, metric):
  #names are the name of each tests from results
  names = set()
  # Row of new data set 
  rows = []
  w_bw_workload = {}

  for k, row in df.iterrows():
    w = row['WORKLOAD']
    n = row['NAME']
    names.add(n)
    values = w_bw_workload.get(w, {})
    values[n] = row[metric]
    w_bw_workload[w] = values
  
  names = list(names)
  cols = ['WORKLOAD'] + list(names) 
  w_bw = pd.DataFrame(w_bw_workload,columns = cols)
 
  for k in w_bw_workload:
    d = w_bw_workload[k]
    
    if not d[names[0]] == 0:
      d["WORKLOAD"] = k;
      w_bw = w_bw.append(d,ignore_index=True)
  return names, w_bw 

#@title fn plot_df
def plot_df(df, names,sort_key=""):
  if sort_key != "":
    df.sort_values(sort_key, ascending=False)
  df.plot(kind='bar',x="WORKLOAD",y=names,  figsize=(30, 10))

def import_data_from_csv():
    results_file="./results/results.csv"
    return pd.read_csv(results_file)

def show_df(df):
    pd.set_option('display.max_rows', df.shape[0]+1)
    return df

def print_qemu_cmd(cmd_file):
    q_cmd = open(cmd_file, 'r') 
    lines = q_cmd.readlines()
    for line in lines:
        if "system-x86_64" in line:
            q=re.split('\s+', line)
            q=q[10:]
            q=' '.join(q)
            q=re.sub("/run.*?,", "...", q)
            display(Markdown('*Qemu:*'))
            display(Markdown('```'+q+'```'))
            
def print_virtiofsd_cmd(cmd_file):
    q_cmd = open(cmd_file, 'r') 
    lines = q_cmd.readlines()
    for line in lines:
        if not "grep" in line:
            q=re.split('\s+', line)
            q=q[10:]
            q=' '.join(q)
            q=re.sub("/run.*?,", "...", q)
            display(Markdown('*virtiofsd:*'))
            display(Markdown('```'+q+'```'))

def print_docker_info(docker_info):
    info = open(docker_info, 'r') 
    lines = info.readlines()
    for line in lines:
        if  "Storage" in line:
            display(Markdown('*docker storage info*'))
            print(line)
            

def print_tests_info():
    subdirs = [f.path for f in os.scandir("./results") if f.is_dir()]
    print("Results")
    for r in subdirs:
        print(r)
        print_qemu_cmd(r+"/qemu_cmd")
        print_virtiofsd_cmd(r+"/virtiofsd_cmd")
        print_docker_info(r+"/docker_info")