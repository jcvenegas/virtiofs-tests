import pandas
import matplotlib
def get_op_by_process(rdf,op):
    pnames = rdf.process.unique()
    df = pandas.DataFrame()
    for k, row in rdf.iterrows():
        d = {}
        d["second"] = row["second"]
        add = False
        for focus in ["qemu", "kworker", "fio", "virtio"]:
            if focus in row["process"]:
                add = True
                break
        if add != True:
            continue
            
        if "kworker" in row["process"]:
            c="kworker"
        
        c=row["process"]
        val = row[op]
        if op == "read":
            c="r-" + c
        if op == "write":
            c="w-" + c

        if val != 0:
            d[c] = val
            df = df.append(d,ignore_index=True)
    return df

def plot_iotop_by_process(df):
    c=set(df.columns)
    c.remove("second")
    df.plot(x="second",y=c,  figsize=(30, 10))
    matplotlib.pyplot.show()

def import_data_from_csv(f):
    return pandas.read_csv(f)