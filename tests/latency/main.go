package main

import (
	"fmt"
	"github.com/aoeldemann/gofluent10g"
	"github.com/aoeldemann/gofluent10g/utils"
	"os"
	"sort"
	"time"
)

var (
	// measurement data rates
	datarates = []float64{10e9}

	// meausrement packet sizes
	pktlens = []int{64, 128, 256, 384, 512, 640, 768, 896, 1024, 1152, 1280, 1408, 1518}

	// generator interface id
	ifGen = 0

	// receiver interface id
	ifRecv = 1

	// measurement duration
	duration = 10 * time.Second
)

func main() {
	// set log level to INFO to reduce verbosity of output
	gofluent10g.LogSetLevel(gofluent10g.LOG_INFO)

	// open network tester
	nt := gofluent10g.NetworkTesterCreate()
	defer nt.Close()

	// get generator and receivers
	gen := nt.GetGenerator(ifGen)
	recv := nt.GetReceiver(ifRecv)

	// enable packet capture on receiver interface. since we are only
	// interested in packet latency, we disable the capturing of packet data
	recv.EnableCapture(true)
	recv.SetCaptureMaxLen(0)

	// set up timestamping
	nt.SetTimestampMode(gofluent10g.TimestampModeFixedPos)
	nt.SetTimestampPos(0)
	nt.SetTimestampWidth(24)

	// iterate over all data rates
	for i, datarate := range datarates {

		// assemble output filename for this run
                filename := fmt.Sprintf("output/latency_%d.dat", int(datarate))

                // open output file for writing
                file, err := os.Create(filename)
                if err != nil {
                	gofluent10g.Log(gofluent10g.LOG_ERR, "could not create file '%s'", filename)
                        return
                }
                defer file.Close()		

		// iterate over all packet sizes
		for j, pktlen := range pktlens {
			gofluent10g.Log(gofluent10g.LOG_INFO, "%d/%d: Datarate: %.2f bps, Packet length: %d", (i*len(pktlens) + j + 1), len(datarates)*len(pktlens), datarate, pktlen)

			gofluent10g.LogIncrementIndentLevel()

			gofluent10g.Log(gofluent10g.LOG_INFO, "Generating trace ...")

			// generate CBR trace data with fixed packet length. Trace duration
			// is 10 seconds. we only transfer the first 34 bytes of each
			// packet down to hardware (contains ethernet and ipv4 headers),
			// hardware will append zero bytes before transmission to restore
			// the original packet lengths
			trace := utils.GenTraceCBR(datarate, pktlen, 34, duration, 1)

			// assign trace to generator
			gen.SetTrace(trace)

			// calculate the host memory size we need to store the capture data.
			// we only store meta data (8 byte) for each packet, no packet
			// data
			captureMemSize := uint64(trace.GetPacketCount()) * 8

			// set receiver capture host memory size
			recv.SetCaptureHostMemSize(captureMemSize)

			// write config to hardware
			nt.WriteConfig()

			gofluent10g.Log(gofluent10g.LOG_INFO, "Starting replay and capture ...")

			// start capturing
			nt.StartCapture()

			// start replay (blocks until replay finished)
			nt.StartReplay()

			gofluent10g.Log(gofluent10g.LOG_INFO, "Replay done")

			// wait a little to make sure all packets have been captured
			time.Sleep(time.Second)

			// stop capturing
			nt.StopCapture()

			gofluent10g.Log(gofluent10g.LOG_INFO, "Capture done")

			// get capture data structure
			capture := recv.GetCapture()

			// get captured packets
			pkts := capture.GetPackets()

			gofluent10g.Log(gofluent10g.LOG_INFO, "Calculating latency statistics ...")

			// calculate latency mean and std dev
			latencyMean := utils.CalcLatencyMean(pkts)
			latencyStd := utils.CalcLatencyStdDev(pkts, latencyMean)

			// sort packets in ascending latency order
			sort.Sort(gofluent10g.CapturePacketsSortByLatency(pkts))

			// get minimum and maximum latency in nanoseconds
			latencyMin := pkts[0].Latency * 1e9
			latencyMax := pkts[len(pkts)-1].Latency * 1e9

			// calculate latency mean and stddev in nanoseconds
			latencyMean *= 1e9
			latencyStd *= 1e9

			// output some infos
			gofluent10g.Log(gofluent10g.LOG_INFO, "Min latency: %.2f ns", latencyMin)
			gofluent10g.Log(gofluent10g.LOG_INFO, "Max latency: %.2f ns", latencyMax)
			gofluent10g.Log(gofluent10g.LOG_INFO, "Mean latency: %.2f ns", latencyMean)
			gofluent10g.Log(gofluent10g.LOG_INFO, "Stddev latency: %.2f ns", latencyStd)

			gofluent10g.Log(gofluent10g.LOG_INFO, "Writing latency to output file '%s' ...", filename)

			// write latency values to file
			file.WriteString(fmt.Sprintf("%d %f\n", pktlen, latencyMean))

			// reset pointers pointing to data we do not need anymore
			trace = nil
			capture = nil
			pkts = nil

			// free memory
			nt.FreeHostMemory()

			gofluent10g.LogDecrementIndentLevel()
		}
	}
}
