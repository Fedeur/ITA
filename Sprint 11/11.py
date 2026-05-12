# %% [markdown]
# <div style="background-color: #84bfef; padding: 20px; border-radius: 10px">
# 
# # Sprint 11 - Visualización de Datos con Python y Power BI
# </div>

# %% [markdown]
# # Librerías

# %%
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import plotly as go
from matplotlib.colors import LinearSegmentedColormap
from sqlalchemy import create_engine
from getpass import getpass
from sqlalchemy import inspect

# %%
#  Paleta de colores para visualizaciones de datos

paleta_azul = [
    "#1e40af",  
    "#2563eb",  
    "#3b82f6",  
    "#38bdf8",  
    "#0ea5e9"
]

paleta_morada = [
    "#ede9fe",  
    "#c4b5fd",
    "#a78bfa",
    "#8b5cf6",
    "#5b21b6"  
]

paleta_celeste = [
    "#bfdbfe",
    "#93c5fd",
    "#60a5fa",
    "#3b82f6",
    "#1d4ed8"
]
paleta_verde = [
    "#dcfce7",
    "#bbf7d0",
    "#86efac",
    "#4ade80",
    "#166534"
]
paleta_roja = [
    "#fee2e2",
    "#fecaca",
    "#fca5a5",
    "#f87171",
    "#b91c1c"
]

paleta_naranja = [
    "#ffedd5",
    "#fed7aa",
    "#fdba74",
    "#fb923c",
    "#c2410c"
]
paleta_categoria = [
    "#0f766e",  # teal fuerte
    "#2563eb",  # azul
    "#f97316",  # naranja
    "#16a34a",  # verde
    "#db2777"   # rosa fuerte
]

paleta_vibrante = [
    "#22c55e",  # verde
    "#3b82f6",  # azul
    "#eab308",  # amarillo
    "#ec4899",  # rosa
    "#f97316"   # naranja
]
paleta_colorblind = [
    "#0072B2",  # azul
    "#E69F00",  # naranja
    "#F0E442",  # amarillo
    "#009E73",  # verde
    "#D55E00"   # rojizo
]

# %% [markdown]
# <div style="background-color: #84bfef; padding: 10px; border-radius: 5px;">
# 
# # ⭐️ Nivel 1
# 
# </div> 

# %% [markdown]
# <div style="background-color: #c5c8cb; padding: 10px; border-radius: 5px;">
# 1. Conecta Python con MySQL Workbench y carga los datos de tu base de datos de Sprint 4 para utilizarlos en todos los ejercicios.
# 

# %%
# Creo conexión con BBDD MySQL

usuario = input('Usuario: ')
password = getpass('Contraseña: ')
puerto = input('Puerto: ')
bbdd = input('Base de datos: ')


engine = create_engine(f'mysql+mysqlconnector://{usuario}:{password}@localhost:{puerto}/{bbdd}')

# %%
inspector = inspect(engine)
tablas = inspector.get_table_names()


# %% [markdown]
# ## Recuerdo del digrama / relaciones <br>
# ![image.png](attachment:image.png) 
# 
# 

# %%
# Los nombres de las tablas los transformo en variables globales:

for nombre in tablas:
    globals()[f'{nombre}'] = pd.read_sql_table(nombre, engine)    

# %%
for nombre in tablas:
    globals()['nombre']

# %%
companies = pd.read_sql_table('companies', engine)
companies

# %%
companies["country"].value_counts().plot.bar(color='b', xlabel='Paises', ylabel='Empresas', rot=80, title='Distribución de empresas por país');  
plt.axhline(y=3, color='red', linestyle='--', linewidth=2, label='Objetivo (3)')
plt.legend()
plt.show()

# %% [markdown]
# ----------
# <div style="background-color: #c5c8cb; padding: 10px; border-radius: 5px;">
# 2. Para cada elemento, crea una vista adecuada según las variables especificadas.<br> Interpreta los resultados según sus datos.
# 
# Recuerda: cuando selecciones las columnas, piensa siempre en el método que vas a utilizar e incluye las necesarias para la función de visualización que quieras utilizar . <br>
# Una variable numérica. <br>
# Dos variables numéricas.<br>
# Una variable categórica.<br>
# Una variable categórica y una numérica. <br>
# Dos variables categóricas. <br>
# Tres variables combinadas. <br>
# Crea un Pairplot. <br>

# %% [markdown]
# _________________________________________________________
# <div style="background-color: #84bfef44; padding: 10px; border-radius: 5px;">
# 
# ## 1 Variable Numérica
# </div> 

# %%
transactions['amount'].plot.hist(xlabel='Importe USD', ylabel= 'Frecuencia', title='Histograma de la columna Importe de transacciones');

# %% [markdown]
# 
# # Interpretación:
# La mayoría de las transacciones se centran en importes bajos entre los 100 - 400 USD, importe típico cercano a 200. <br>
# Se observa una curvatura hacia la derecha, ya que existen transacciones poco frecuentes de alto importe, con un máximo superior a 800 USD.
# 

# %% [markdown]
# _________________________________________________________
# <div style="background-color: #84bfef44; padding: 10px; border-radius: 5px;">
# 
# # Dos variables Numéricas
# </div>

# %%
transacc_usuarios = (transactions.groupby("user_id")["amount"].agg(num_transacciones="count", importe_medio="mean"))

plt.figure(figsize=(10, 6))
sns.scatterplot(data=transacc_usuarios, x='num_transacciones', y='importe_medio', color='g', alpha=.5)
plt.xlabel('Transacciones')
plt.ylabel('Importe medio USD')
plt.title("Número de transacciones vs Importe medio por usuario")

plt.show()

# %% [markdown]
# # Interpretación:
# El número de transacciones vemos que queda agrupado entre los valores más bajos, con un máximo de 40 transacciones por usuario, el resto serían outliers. <br>
# El importe medio de transacciones vemos que ronda el valor del ticket medio que son 260 USD.  

# %% [markdown]
# _________________________________________________________
# <div style="background-color: #84bfef44; padding: 10px; border-radius: 5px;">
# 
# # 1 Variable Categórica 
# <div/>

# %%
companies["country"].value_counts().plot.bar(color='b', xlabel='Paises', ylabel='Empresas', rot=80, title='Distribución de empresas por país');  
plt.axhline(y=3, color='red', linestyle='--', linewidth=2, label='Objetivo (3)')
plt.legend()
plt.show()

# %% [markdown]
# # Interpretación:
# La distribución de compañías no es homogénea entre países. Suecia y Países Bajos concentran el mayor número de empresas, mientras que países como España 
# y China presentan una menor representación. <br> 
# Esto indica una mayor presencia empresarial en determinados mercados.

# %% [markdown]
# _________________________________________________________
# <div style="background-color: #84bfef44; padding: 10px; border-radius: 5px;">
# 
# ## 1 Variable Categórica (companies['company_name']) y 1 Numérica (products['Amount'])
# <div/>

# %%
df_merge = transactions.merge(
    companies,
    left_on="business_id",
    right_on="company_id",
    how="left"
)
df_merge = df_merge.merge(
    transaction_products,
    left_on="id",
    right_on="transaction_id",
    how="left"
)
df_merge = df_merge.merge(
    products,
    left_on="product_id",
    right_on="id",
    how="left"
)


# %%
plt.figure(figsize=(12, 6))

df_merge.loc[df_merge['country'] == 'Germany'].groupby("company_name")["amount"].mean().sort_values(ascending=False).plot.bar(
    color='steelblue',
    rot=70,
    title='Importe medio por empresa (Alemania)'
)
plt.axhline(y=260, color='red', linestyle='--', linewidth=2, label='Objetivo (260)')
plt.legend()
plt.xlabel('Empresas')
plt.ylabel('Importe medio ($)')
plt.tight_layout()
plt.show()

# %% [markdown]
# # Interpretación:
# Las empresas alemanas presentan importes medios de transacción similares, entre 300 y 350 €. <br>
# Ac Fermentum Incorporated lidera con el importe medio más alto (~347 €), mientras que el resto se agrupa en torno a los 300 €, lo que indica una distribución bastante homogénea
# del ticket medio en el mercado Aleman.

# %% [markdown]
# _________________________________________________________
# <div style="background-color: #84bfef44; padding: 10px; border-radius: 5px;">
# 
# ## Dos Variables Categóricas (Barras)
# <div/>

# %%
# Top 5 productos por país
top_products = df_merge['product_name'].value_counts().head(5).index
tabla = pd.crosstab(
    df_merge[df_merge['product_name'].isin(top_products)]['country'],
    df_merge[df_merge['product_name'].isin(top_products)]['product_name'])

# %%
tabla.plot.bar(stacked=True, xlabel='País', ylabel='Cantidad', figsize=(8,6), rot=70)

plt.show()

# %% [markdown]
# # Interpretación:
# Suecia e Holanda son los países con mayor volumen de productos vendidos <br>
# En países como China o Norway el volumen total es muy bajo comparado con el resto.

# %% [markdown]
# _________________________________________________________
# <div style="background-color: #84bfef44; padding: 10px; border-radius: 5px;">
# 
# ## Tres Variables Combinadas (scatterplot)
# <div/>

# %%
resumen = (df_merge.groupby("country", observed=False)["amount"]
           .agg(["mean", "count"])
           .sort_values("mean"))

# Asignar un color a cada país según su volumen de transacciones
volumen = resumen["count"]
rangos = np.linspace(volumen.min(), volumen.max(), 5)

color_pais = []
for v in volumen:
    for i in range(len(rangos) - 1):
        if rangos[i] <= v <= rangos[i + 1]:
            color_pais.append(paleta_categoria[i])
            break

# %%
# modificar leyendas hay eur y guiones

import plotly.express as px

plt.figure(figsize=(15, 12))
fig = px.scatter(
    resumen.reset_index(),
    x="country",
    y="mean",
    size="count",
    color="count",
    title="Importe medio y volumen de transacciones por país",
    labels={"mean": "Importe medio ($)", "country": "País", "count": "Nº transacciones"},
    color_continuous_scale="Plasma",
    size_max=60
)
fig.show()

# %% [markdown]
# # INTERPRETACION:
# El gráfico revela que los mercados de mayor volumen de transacciones (UK, Netherlands, Canada) no son necesariamente los de mayor valor por transacción, <br>
# mientras que mercados como Germany, Australia o United States combinan un ticket medio elevado con un volumen significativo, <br>
# lo que los convierte en los mercados más rentables en términos absolutos. <br>

# %% [markdown]
# _________________________________________________________
# <div style="background-color: #84bfef44; padding: 10px; border-radius: 5px;">
# 
# ## Pairplot 
# 
# <div>

# %%

# Top 5 compañías por número de transacciones

top_companies = (df_merge['company_name'].value_counts().head(5).index)
df_top_companies = df_merge[df_merge['company_name'].isin(top_companies)]
sns.pairplot(df_top_companies, vars=['amount', 'weight', 'price'], hue='company_name');
plt.show()

# %% [markdown]
# <div style="background-color: #84bfef; padding: 10px; border-radius: 5px;">
# 
# # ⭐️⭐️ Nivel 2
# 
# </div> 

# %% [markdown]
# <div style="text-align:left; margin-top:20px; margin-bottom:20px;">
# <h3 style="color:#5C7FA3; text-align:left; font-size:18px;">
# 1. Representa la correlación de algunas variables e interpreta los resultados según tus datos.<br>
# 2. Implementa un Jointplot para explorar la relación entre dos variables e interpreta los resultados según tus datos.<br>
# </h3>
# 
# </div>

# %% [markdown]
# _________________________________________________________
# <div style="background-color: #84bfef44; padding: 10px; border-radius: 5px;">
# 
# ## 1) Matríz de Correlación

# %%
df_corr = df_merge[["amount", "price", "weight"]]

corr = df_corr.corr() # corr de Pearson es la q sale x default ( solo se puede hacer cuando la correlac es normal) 

custom_cmap = LinearSegmentedColormap.from_list(
    "custom_blue",
    paleta_celeste
)

plt.figure(figsize=(9,6))

sns.heatmap(
    corr,
    annot=True,
    cmap='coolwarm',
    center=0,      
    vmin=-1,
    vmax=1,
    fmt=".2f"
)

plt.title('Correlación entre variables de comportamiento del usuario')
plt.show()

# Interpretación:
# num_transacciones y gasto_total tienen correlación muy alta (0.96): lógico, más compras = más gasto.
# tasa_rechazo tiene correlación moderada con num_transacciones (0.30): usuarios que más compran tienen más rechazos.
# El importe medio (amount) no correlaciona con ninguna variable del comportamiento del usuario.

# %% [markdown]
# _________________________________________________________
# <div style="background-color: #84bfef44; padding: 10px; border-radius: 5px;">
# 
# ## 2) Joinplot de relación entre dos variables

# %%
# Agrupo por cliente
df_clientes = df_merge.groupby('card_id').agg(
    num_transacciones=('amount', 'count'),
    gasto_total=('amount', 'sum')
).reset_index()

# Filtro outliers con IQR
Q1 = df_clientes['num_transacciones'].quantile(0.25)
Q3 = df_clientes['num_transacciones'].quantile(0.75)
IQR = Q3 - Q1
df_sin_outliers = df_clientes[df_clientes['num_transacciones'] <= Q3 + 1.5 * IQR]

g = sns.jointplot(
    data=df_sin_outliers,
    x='num_transacciones',
    y='gasto_total',
    kind='hex',
    height=6,
)

g.fig.suptitle(
    'Frecuencia de compra vs gasto total por cliente',
    y=1.02
)

g.fig.set_size_inches(9,6)

plt.show()

# Interpretación:
# Los clientes con más transacciones acumulan un mayor gasto total.
# La mayor densidad se concentra entre 20-80 compras y 5.000-25.000 USD de gasto.
# Existe una correlación positiva clara entre frecuencia de compra y gasto acumulado.

# %% [markdown]
# <div style="background-color: #84bfef; padding: 10px; border-radius: 5px;">
# 
# # ⭐️⭐️⭐️ Nivel 3
# 
# </div> 

# %% [markdown]
# Recuerda: cuando cargues tus dataframes en Power BI, asegúrate de incluir una columna identificadora o una combinación de columnas que garantice la unicidad de cada registro. Por defecto, Power BI elimina duplicados y podrías perder información .

# %% [markdown]
# ## Conexión en PowerBI realizada con el siguente script:
# 
# import pandas as pd
# from sqlalchemy import create_engine, inspect
# 
# usuario = "powerbi"
# password = "Fede00542281423818"
# host = "192.168.0.31"
# puerto = 3306
# bbdd = "sprint04"
# 
# engine = create_engine(
#     f"mysql+mysqlconnector://{usuario}:{password}@{host}:{puerto}/{bbdd}"
# )
# 
# inspector = inspect(engine)
# tablas = inspector.get_table_names()
# 
# dataset = pd.read_sql("SELECT * FROM companies", con=engine)

# %% [markdown]
# 


