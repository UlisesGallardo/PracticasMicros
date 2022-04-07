using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.IO.Ports;
namespace WindowsFormsApplication1
{
    public partial class Form1 : Form
    {
        SerialPort spPuertoSerie = new SerialPort(
           "COM2", 4800, Parity.None, 8, StopBits.Two);
        
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            Control.CheckForIllegalCrossThreadCalls = false; 
            spPuertoSerie.DataReceived += new SerialDataReceivedEventHandler(sPuerto_DataReceived);

            try //intenta hacer lo que hay dentro de este try
            {
                //sPuerto.Open(); //abrir el puerto serial
                spPuertoSerie.Open();
            }
            catch (Exception ex)
            {
                MessageBox.Show("ERROR AL ABRIR EL PUERTO SERIAL\n\n" + ex); //Me muestra el error
                Application.Exit(); //cierra el programa
            }
            if (spPuertoSerie.IsOpen)
            {
                //MessageBox.Show("TEXTO","TÍTULO");
                //A continuación se muestra la información del puerto (si se desea cambiar se debe hacer desde las propiedades del puerto)
                MessageBox.Show("El puerto " + spPuertoSerie.PortName + " se abrió con una velocidad de " + spPuertoSerie.BaudRate + "\nParidad: " + spPuertoSerie.Parity + "\nNúmero de bits: " + spPuertoSerie.DataBits + "\nBits de parada: " + spPuertoSerie.StopBits, "Información de la conexión");
            }
        }

        //public static void DataReceivedHandler
        private void sPuerto_DataReceived(object sender, System.IO.Ports.SerialDataReceivedEventArgs e)
        {
            int Dato = spPuertoSerie.ReadByte();
            double voltaje = Dato * 5 / 255.0;
            Console.WriteLine(voltaje);
            this.lblDato.Text = Convert.ToString(Dato);
            //spPuertoSerie.Write("C"+Convert.ToString(voltaje));

            string v = Convert.ToString(voltaje);
            int n = v.Length + 1;

            Byte[] info = new Byte[n];
            info[0] = Convert.ToByte('C');
            int j = 1;
            foreach (char c in v)
            {
                info[j] = Convert.ToByte(c);
                j++;
            }

            spPuertoSerie.Write(info,0,n);
        }

        private void timer1_Tick(object sender, EventArgs e)
        {

        }

        private void lblDato_Click(object sender, EventArgs e)
        {

        }

        private void label7_Click(object sender, EventArgs e)
        {

        }
    }
}
