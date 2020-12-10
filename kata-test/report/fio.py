import pandas as pd

def load_from_colab_form():
    from google.colab import files
    uploaded = files.upload()

    for fn in uploaded.keys():
      print('User uploaded file "{name}" with length {length} bytes'.format(
      name=fn, length=len(uploaded[fn])))
    
    if not results_file in uploaded:
       raise Exception("Not found results file")
    
def check_results_file(results_file):
    if 'google.colab' in str(get_ipython()):
      print('Running on CoLab')
      load_from_colab_form()
    else:
      from os import path
      if not path.exists(results_file):
        raise Exception("Not found results file")

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

def import_data_from_csv(results_file):
    return pd.read_csv(results_file)

def show_df(df):
    pd.set_option('display.max_rows', df.shape[0]+1)
    return df
