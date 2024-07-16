using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Management.Automation;

namespace VSYSDevOps.Utility
{
    public class WSLDistroEntry {
        public string? DistroName { get; set; }
        public string? IsDefault { get; set; }
        public string? State { get; set; }
        public int? Version { get; set; }
        public WSLDistroEntry () { }
        public WSLDistroEntry(string distroName, string isDefault, string state, int version) {
            DistroName = distroName;
            IsDefault  = isDefault;
            State      = state;
            Version    = version;
        }
    }

    public class WSLInformation {
        public bool WSLExeFound { get; set; }
        public bool WSLOptionalComponentInstalled { get; set; }
        public bool WSLDistroInstalled { get; set; }
        public List<WSLDistroEntry> WSLAllDistroInformation { get; }
        public bool WSLBrokenDistributionsPresent { get; set; }
        public bool WSLUnknownErrorExists { get; set; }
        public bool WSLServiceExists { get; set; }
        public bool WSLServiceRunning { get; set; }
        public bool WSLVersion { get; set; }
        public bool WSLKernelVersion { get; set; }
        public bool WSLgVersion { get; set; }
        public bool WSLMSRDCVersion { get; set; }
        public bool WSLDirect3DVersion { get; set; }
        public bool WSLDXCoreVersion { get; set; }
        public bool WSLWindowsVersion { get; set; }
        public bool WSLDefaultDistro { get; set; }
        public bool WSLDefaultVersion { get; set; }
        public WSLInformation () { }
        public void AddInstalledWSLDistro (string distroName, string isDefault, string distroState, int distroVersion) {
            WSLAllDistroInformation.Add(new WSLDistroEntry(distroName, isDefault, distroState, distroVersion));
        }
    }
}